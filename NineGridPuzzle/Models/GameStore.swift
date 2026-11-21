import UIKit
import Combine

struct PuzzleRecord: Codable {
    var bestTime: Double = 0
    var bestMoves: Int = 0
    var plays: Int = 0
}

struct PuzzlePhoto: Identifiable {
    let id: Int
    let name: String
    let sub: String
    let asset: String
}

enum Difficulty: Int, CaseIterable, Identifiable, Equatable {
    case easy = 3
    case medium = 4
    case hard = 5

    var id: Int { rawValue }
    var title: String { "\(rawValue) × \(rawValue)" }

    var note: String {
        switch self {
        case .easy: return "轻松上手"
        case .medium: return "渐入佳境"
        case .hard: return "挑战极限"
        }
    }
}

enum PuzzleLibrary {
    static let photos: [PuzzlePhoto] = [
        PuzzlePhoto(id: 0, name: "樱花庭院", sub: "春日 · 京都", asset: "photo1"),
        PuzzlePhoto(id: 1, name: "极光雪原", sub: "深夜 · 极北", asset: "photo2"),
        PuzzlePhoto(id: 2, name: "椰林落日", sub: "黄昏 · 海岸", asset: "photo3"),
        PuzzlePhoto(id: 3, name: "橘猫午后", sub: "午后 · 暖阳", asset: "photo4"),
        PuzzlePhoto(id: 4, name: "霓虹雨夜", sub: "午夜 · 都市", asset: "photo5")
    ]

    static func image(for photo: PuzzlePhoto) -> UIImage {
        if let image = UIImage(named: photo.asset) { return image }
        return placeholder(named: photo.name)
    }

    private static func placeholder(named name: String) -> UIImage {
        let size = CGSize(width: 900, height: 900)
        let renderer = UIGraphicsImageRenderer(size: size)
        return renderer.image { context in
            let colors = [UIColor(red: 0.93, green: 0.29, blue: 0.60, alpha: 1).cgColor,
                          UIColor(red: 0.55, green: 0.36, blue: 0.96, alpha: 1).cgColor]
            if let gradient = CGGradient(colorsSpace: CGColorSpaceCreateDeviceRGB(),
                                         colors: colors as CFArray,
                                         locations: [0, 1]) {
                context.cgContext.drawLinearGradient(gradient,
                                                     start: .zero,
                                                     end: CGPoint(x: size.width, y: size.height),
                                                     options: [])
            }
            let attributes: [NSAttributedString.Key: Any] = [
                .font: UIFont.systemFont(ofSize: 64, weight: .bold),
                .foregroundColor: UIColor.white
            ]
            let text = name as NSString
            let textSize = text.size(withAttributes: attributes)
            text.draw(at: CGPoint(x: (size.width - textSize.width) / 2,
                                  y: (size.height - textSize.height) / 2),
                      withAttributes: attributes)
        }
    }
}

final class GameStore: ObservableObject {
    private let defaults = UserDefaults.standard

    @Published var photoIndex: Int {
        didSet { defaults.set(photoIndex, forKey: Keys.photo) }
    }

    @Published var difficulty: Int {
        didSet { defaults.set(difficulty, forKey: Keys.difficulty) }
    }

    @Published var haptics: Bool {
        didSet { defaults.set(haptics, forKey: Keys.haptics) }
    }

    @Published var showNumbers: Bool {
        didSet { defaults.set(showNumbers, forKey: Keys.numbers) }
    }

    @Published private(set) var stats: [String: PuzzleRecord] = [:]

    private enum Keys {
        static let photo = "ng.photo"
        static let difficulty = "ng.difficulty"
        static let haptics = "ng.haptics"
        static let numbers = "ng.numbers"
        static let stats = "ng.stats"
    }

    init() {
        let defaults = UserDefaults.standard
        photoIndex = defaults.object(forKey: Keys.photo) as? Int ?? 0
        difficulty = defaults.object(forKey: Keys.difficulty) as? Int ?? Difficulty.easy.rawValue
        haptics = defaults.object(forKey: Keys.haptics) as? Bool ?? true
        showNumbers = defaults.object(forKey: Keys.numbers) as? Bool ?? false

        if let data = defaults.data(forKey: Keys.stats),
           let decoded = try? JSONDecoder().decode([String: PuzzleRecord].self, from: data) {
            stats = decoded
        }
    }

    func record(for size: Int) -> PuzzleRecord {
        stats["\(size)"] ?? PuzzleRecord()
    }

    func submit(size: Int, time: Double, moves: Int) -> (improvedTime: Bool, improvedMoves: Bool) {
        var record = self.record(for: size)
        record.plays += 1

        var improvedTime = false
        var improvedMoves = false

        if record.bestTime == 0 || time < record.bestTime {
            record.bestTime = time
            improvedTime = true
        }
        if record.bestMoves == 0 || moves < record.bestMoves {
            record.bestMoves = moves
            improvedMoves = true
        }

        stats["\(size)"] = record
        if let data = try? JSONEncoder().encode(stats) {
            defaults.set(data, forKey: Keys.stats)
        }
        return (improvedTime, improvedMoves)
    }
}
