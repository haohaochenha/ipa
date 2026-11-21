import AVFoundation

final class SoundPlayer {
    static let shared = SoundPlayer()

    private let movePlayer: AVAudioPlayer?
    private let winPlayer: AVAudioPlayer?

    private init() {
        let session = AVAudioSession.sharedInstance()
        try? session.setCategory(.ambient, options: [.mixWithOthers])
        movePlayer = SoundPlayer.makePlayer(samples: SoundPlayer.moveSamples())
        winPlayer = SoundPlayer.makePlayer(samples: SoundPlayer.winSamples())
    }

    func playMove(enabled: Bool) {
        play(movePlayer, enabled: enabled)
    }

    func playWin(enabled: Bool) {
        play(winPlayer, enabled: enabled)
    }

    private func play(_ player: AVAudioPlayer?, enabled: Bool) {
        guard enabled, let player = player else { return }
        player.currentTime = 0
        player.play()
    }

    // MARK: - 音色合成

    private static let sampleRate: Double = 22050

    private static func makePlayer(samples: [Float]) -> AVAudioPlayer? {
        let data = wavData(from: samples)
        guard let player = try? AVAudioPlayer(data: data) else { return nil }
        player.volume = 0.7
        player.prepareToPlay()
        return player
    }

    private static func wavData(from samples: [Float]) -> Data {
        var data = Data()
        let byteCount = UInt32(samples.count * 2)
        let rate = UInt32(sampleRate)

        func write<T: FixedWidthInteger>(_ value: T) {
            var little = value.littleEndian
            withUnsafeBytes(of: &little) { data.append(contentsOf: $0) }
        }

        data.append(contentsOf: Array("RIFF".utf8))
        write(UInt32(36) + byteCount)
        data.append(contentsOf: Array("WAVE".utf8))
        data.append(contentsOf: Array("fmt ".utf8))
        write(UInt32(16))
        write(UInt16(1))
        write(UInt16(1))
        write(rate)
        write(rate * 2)
        write(UInt16(2))
        write(UInt16(16))
        data.append(contentsOf: Array("data".utf8))
        write(byteCount)

        for sample in samples {
            let clamped = max(-1, min(1, sample))
            write(Int16(clamped * 32000))
        }
        return data
    }

    private static func moveSamples() -> [Float] {
        let count = Int(sampleRate * 0.075)
        var samples = [Float](repeating: 0, count: count)
        for i in 0..<count {
            let t = Double(i) / sampleRate
            let progress = Double(i) / Double(count)
            let envelope = pow(1 - progress, 3.5)
            let frequency = 1400 - 620 * progress
            let tone = sin(2 * Double.pi * frequency * t)
            let body = 0.4 * sin(2 * Double.pi * frequency * 0.5 * t)
            samples[i] = Float((tone + body) * envelope * 0.30)
        }
        return samples
    }

    private static func winSamples() -> [Float] {
        let notes: [(frequency: Double, start: Double)] = [
            (523.25, 0.00),
            (659.25, 0.10),
            (783.99, 0.20),
            (1046.50, 0.30),
        ]
        let count = Int(sampleRate * 1.1)
        var samples = [Float](repeating: 0, count: count)
        for i in 0..<count {
            let t = Double(i) / sampleRate
            var value = 0.0
            for note in notes {
                let local = t - note.start
                if local < 0 || local > 0.75 { continue }
                let envelope = exp(-local * 5.5) * min(1, local * 200)
                value += sin(2 * Double.pi * note.frequency * local) * envelope * 0.22
                value += 0.3 * sin(2 * Double.pi * note.frequency * 2 * local) * envelope * 0.22
            }
            samples[i] = Float(min(1, max(-1, value)))
        }
        return samples
    }
}
