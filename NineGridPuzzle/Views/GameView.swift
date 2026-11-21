import SwiftUI
import Combine
import UIKit

struct GameView: View {
    let photo: PuzzlePhoto
    let difficulty: Difficulty
    @ObservedObject var store: GameStore
    var onExit: () -> Void

    @StateObject private var game: PuzzleGame
    @State private var startDate: Date?
    @State private var endDate: Date?
    @State private var now = Date()
    @State private var showWin = false
    @State private var newRecord = false
    @State private var showOriginal = false

    private let ticker = Timer.publish(every: 0.2, on: .main, in: .common).autoconnect()

    init(photo: PuzzlePhoto,
         difficulty: Difficulty,
         store: GameStore,
         onExit: @escaping () -> Void) {
        self.photo = photo
        self.difficulty = difficulty
        self.onExit = onExit
        _store = ObservedObject(wrappedValue: store)
        _game = StateObject(wrappedValue: PuzzleGame(size: difficulty.rawValue,
                                                     image: PuzzleLibrary.image(for: photo)))
    }

    private var elapsed: TimeInterval {
        guard let start = startDate else { return 0 }
        return max(0, (endDate ?? now).timeIntervalSince(start))
    }

    private var timeText: String {
        Formats.clock(elapsed)
    }

    var body: some View {
        ZStack {
            VStack(spacing: 16) {
                topBar
                statsBar

                Spacer(minLength: 0)

                PuzzleBoard(board: game.board,
                            size: game.size,
                            tiles: game.tiles,
                            fullImage: game.image,
                            showsNumbers: store.showNumbers,
                            showsOriginal: showOriginal,
                            onTap: { tileID in handleTap(tileID) })
                    .padding(10)
                    .glass(radius: 30)

                Spacer(minLength: 0)

                footer
            }
            .padding(.horizontal, 20)
            .padding(.top, 10)
            .padding(.bottom, 22)

            if showWin {
                winOverlay
            }
        }
        .onReceive(ticker) { _ in
            if startDate != nil, endDate == nil {
                now = Date()
            }
        }
    }

    private var topBar: some View {
        HStack(spacing: 12) {
            GlassIconButton(icon: "chevron.left") {
                onExit()
            }

            Spacer(minLength: 0)

            VStack(spacing: 2) {
                Text(photo.name)
                    .font(Theme.rounded(16, .bold))
                    .foregroundColor(Theme.ink)
                Text("\(difficulty.title) · \(difficulty.note)")
                    .font(Theme.rounded(11, .medium))
                    .foregroundColor(Theme.subInk)
            }

            Spacer(minLength: 0)

            GlassIconButton(icon: "arrow.counterclockwise") {
                restart()
            }
        }
    }

    private var statsBar: some View {
        HStack(spacing: 10) {
            metric(icon: "timer", title: "用时", value: timeText)
            metric(icon: "hand.tap.fill", title: "步数", value: "\(game.moves)")

            GlassIconButton(icon: showOriginal ? "eye.fill" : "eye") {
                withAnimation(.easeOut(duration: 0.2)) {
                    showOriginal.toggle()
                }
                if store.haptics { Haptics.tap() }
            }
            .accessibilityLabel(showOriginal ? "关闭原图预览" : "预览原图")
        }
    }

    private func metric(icon: String, title: String, value: String) -> some View {
        HStack(spacing: 9) {
            Image(systemName: icon)
                .font(.system(size: 14, weight: .semibold))
                .foregroundColor(Theme.pink)

            VStack(alignment: .leading, spacing: 1) {
                Text(title)
                    .font(Theme.rounded(10, .medium))
                    .foregroundColor(Theme.subInk)
                Text(value)
                    .font(Theme.rounded(17, .bold))
                    .foregroundColor(Theme.ink)
                    .monospacedDigit()
            }

            Spacer(minLength: 0)
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 9)
        .frame(maxWidth: .infinity)
        .glass(radius: 18)
    }

    private var footer: some View {
        HStack(spacing: 12) {
            GhostButton(title: "重新开始", icon: "arrow.triangle.2.circlepath") {
                restart()
            }
            GhostButton(title: "返回首页", icon: "house.fill") {
                onExit()
            }
        }
    }

    @ViewBuilder
    private var winOverlay: some View {
        ZStack {
            Color.black.opacity(0.16)
                .ignoresSafeArea()
                .transition(.opacity)

            VStack(spacing: 15) {
                ZStack {
                    Circle()
                        .fill(Theme.goldGradient)
                        .frame(width: 72, height: 72)
                        .shadow(color: Theme.gold.opacity(0.45), radius: 18, x: 0, y: 8)
                    Image(systemName: "checkmark")
                        .font(.system(size: 30, weight: .heavy))
                        .foregroundColor(.white)
                }

                Text(newRecord ? "新的最佳成绩" : "拼好啦")
                    .font(Theme.rounded(24, .bold))
                    .foregroundColor(Theme.ink)

                Text("\(photo.name) · \(difficulty.title)")
                    .font(Theme.rounded(13, .medium))
                    .foregroundColor(Theme.subInk)

                HStack(spacing: 10) {
                    StatPill(title: "用时", value: timeText, highlight: true)
                    StatPill(title: "步数", value: "\(game.moves)")
                }
                .padding(.top, 2)

                PrimaryButton(title: "再来一局", icon: "arrow.counterclockwise") {
                    restart()
                }
                .padding(.top, 4)

                GhostButton(title: "返回首页", icon: "house.fill") {
                    onExit()
                }
            }
            .padding(24)
            .frame(maxWidth: 330)
            .glass(radius: 30)
            .padding(.horizontal, 30)
            .transition(.scale(scale: 0.92).combined(with: .opacity))
        }
    }

    private func handleTap(_ tileID: Int) {
        guard !game.isSolved else { return }

        if startDate == nil {
            startDate = Date()
            now = Date()
        }

        let moved = withAnimation(.spring(response: 0.32, dampingFraction: 0.82)) {
            game.move(tileID: tileID)
        }

        if moved, store.haptics { Haptics.tap() }
        if moved { SoundPlayer.shared.playMove(enabled: store.sound) }
        guard game.isSolved else { return }

        endDate = Date()
        let result = store.submit(size: difficulty.rawValue, time: elapsed, moves: game.moves)
        newRecord = result.improvedTime && result.improvedMoves
        if store.haptics { Haptics.success() }
        SoundPlayer.shared.playWin(enabled: store.sound)

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.28) {
            withAnimation(.spring(response: 0.45, dampingFraction: 0.84)) {
                showWin = true
            }
        }
    }

    private func restart() {
        if store.haptics { Haptics.tap() }
        withAnimation(.spring(response: 0.4, dampingFraction: 0.85)) {
            game.reset()
            startDate = nil
            endDate = nil
            now = Date()
            showWin = false
            newRecord = false
            showOriginal = false
        }
    }
}
