import UIKit
import Combine

final class PuzzleGame: ObservableObject {
    let size: Int
    let image: UIImage
    let tiles: [Int: UIImage]

    @Published private(set) var board: [Int]
    @Published private(set) var moves: Int = 0

    var tileCount: Int { size * size }
    var blankID: Int { tileCount - 1 }
    var blankIndex: Int { board.firstIndex(of: blankID) ?? tileCount - 1 }
    var isSolved: Bool { board == Array(0..<tileCount) }

    init(size: Int, image: UIImage) {
        self.size = size
        self.image = image
        self.tiles = PuzzleGame.slice(image: image, size: size)
        self.board = Array(0..<(size * size))
        shuffle()
    }

    func reset() {
        board = Array(0..<tileCount)
        moves = 0
        shuffle()
    }

    @discardableResult
    func move(tileID: Int) -> Bool {
        guard !isSolved else { return false }
        let moved = slide(tileID: tileID)
        if moved { moves += 1 }
        return moved
    }

    private func slide(tileID: Int) -> Bool {
        guard tileID != blankID, let position = board.firstIndex(of: tileID) else { return false }

        let blank = blankIndex
        let row = position / size
        let col = position % size
        let blankRow = blank / size
        let blankCol = blank % size

        if row == blankRow {
            let base = row * size
            if col < blankCol {
                for c in stride(from: blankCol, to: col, by: -1) {
                    board[base + c] = board[base + c - 1]
                }
            } else {
                for c in stride(from: blankCol, to: col, by: 1) {
                    board[base + c] = board[base + c + 1]
                }
            }
            board[base + col] = blankID
        } else if col == blankCol {
            if row < blankRow {
                for r in stride(from: blankRow, to: row, by: -1) {
                    board[r * size + col] = board[(r - 1) * size + col]
                }
            } else {
                for r in stride(from: blankRow, to: row, by: 1) {
                    board[r * size + col] = board[(r + 1) * size + col]
                }
            }
            board[position] = blankID
        } else {
            return false
        }

        return true
    }

    func movableTileIDs() -> [Int] {
        let blank = blankIndex
        let row = blank / size
        let col = blank % size
        var ids: [Int] = []
        if col > 0 { ids.append(board[blank - 1]) }
        if col < size - 1 { ids.append(board[blank + 1]) }
        if row > 0 { ids.append(board[blank - size]) }
        if row < size - 1 { ids.append(board[blank + size]) }
        return ids
    }

    private func shuffle() {
        let steps = max(120, tileCount * 40)
        var lastTile = -1
        for _ in 0..<steps {
            let candidates = movableTileIDs().filter { $0 != lastTile }
            guard let pick = candidates.randomElement() else { break }
            if slide(tileID: pick) {
                lastTile = pick
            }
        }
        if isSolved, let pick = movableTileIDs().randomElement() {
            _ = slide(tileID: pick)
        }
        moves = 0
    }

    static func slice(image: UIImage, size: Int) -> [Int: UIImage] {
        let target: CGFloat = 1440
        let width = image.size.width
        let height = image.size.height
        let side = min(width, height)
        let scale = target / max(side, 1)

        let renderer = UIGraphicsImageRenderer(size: CGSize(width: target, height: target))
        let normalized = renderer.image { _ in
            image.draw(in: CGRect(x: -(width - side) / 2 * scale,
                                  y: -(height - side) / 2 * scale,
                                  width: width * scale,
                                  height: height * scale))
        }

        guard let cgImage = normalized.cgImage else { return [:] }
        let cellWidth = cgImage.width / size
        let cellHeight = cgImage.height / size
        var result: [Int: UIImage] = [:]

        for r in 0..<size {
            for c in 0..<size {
                let rect = CGRect(x: c * cellWidth, y: r * cellHeight,
                                  width: cellWidth, height: cellHeight)
                if let cropped = cgImage.cropping(to: rect) {
                    result[r * size + c] = UIImage(cgImage: cropped, scale: 1, orientation: .up)
                }
            }
        }
        return result
    }
}
