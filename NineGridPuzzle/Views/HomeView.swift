import SwiftUI
import UIKit

struct HomeView: View {
    @ObservedObject var store: GameStore
    var onStart: (PuzzlePhoto, Difficulty) -> Void

    @State private var showSettings = false

    private let photos = PuzzleLibrary.photos

    private var selectedPhoto: PuzzlePhoto {
        photos.indices.contains(store.photoIndex) ? photos[store.photoIndex] : photos[0]
    }

    private var difficulty: Difficulty {
        Difficulty(rawValue: store.difficulty) ?? .easy
    }

    private var record: PuzzleRecord {
        store.record(for: difficulty.rawValue)
    }

    var body: some View {
        ZStack(alignment: .topTrailing) {
            ScrollView(showsIndicators: false) {
                VStack(spacing: 22) {
                    header
                    heroCard
                    photoStrip
                    difficultySection
                    recordRow
                    PrimaryButton(title: "开始拼图", icon: "square.grid.3x3.fill") {
                        if store.haptics { Haptics.success() }
                        onStart(selectedPhoto, difficulty)
                    }
                    .padding(.top, 2)

                    Text("点按与空位同一行或同一列的方块即可滑动，整行整列都会跟着移动。")
                        .font(Theme.rounded(12, .medium))
                        .foregroundColor(Theme.subInk.opacity(0.9))
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 12)
                }
                .padding(.horizontal, 20)
                .padding(.top, 8)
                .padding(.bottom, 36)
            }

            if showSettings {
                settingsPanel
                    .padding(.trailing, 20)
                    .padding(.top, 64)
                    .transition(.scale(scale: 0.9, anchor: .topTrailing).combined(with: .opacity))
                    .zIndex(3)
            }
        }
    }

    private var header: some View {
        HStack(alignment: .center, spacing: 12) {
            VStack(alignment: .leading, spacing: 4) {
                Text("九格拼图")
                    .font(Theme.rounded(32, .bold))
                    .foregroundColor(Theme.ink)
                Text("把碎片，拼回完整的风景")
                    .font(Theme.rounded(14, .medium))
                    .foregroundColor(Theme.subInk)
            }
            Spacer(minLength: 0)
            GlassIconButton(icon: "slider.horizontal.3") {
                withAnimation(.spring(response: 0.35, dampingFraction: 0.8)) {
                    showSettings.toggle()
                }
            }
        }
    }

    private var heroCard: some View {
        ZStack(alignment: .bottomLeading) {
            Image(uiImage: PuzzleLibrary.image(for: selectedPhoto))
                .resizable()
                .aspectRatio(contentMode: .fill)
                .frame(height: 252)
                .frame(maxWidth: .infinity)
                .clipped()

            LinearGradient(colors: [Color.clear, Color.black.opacity(0.58)],
                           startPoint: .center,
                           endPoint: .bottom)

            VStack(alignment: .leading, spacing: 6) {
                Text(selectedPhoto.name)
                    .font(Theme.rounded(23, .bold))
                    .foregroundColor(.white)
                Text(selectedPhoto.sub)
                    .font(Theme.rounded(13, .medium))
                    .foregroundColor(.white.opacity(0.85))
            }
            .padding(20)
        }
        .frame(height: 252)
        .clipShape(RoundedRectangle(cornerRadius: 28, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 28, style: .continuous)
                .strokeBorder(Color.white.opacity(0.65), lineWidth: 1)
        )
        .overlay(alignment: .topTrailing) {
            Text(difficulty.title)
                .font(Theme.rounded(13, .bold))
                .foregroundColor(.white)
                .padding(.horizontal, 12)
                .padding(.vertical, 7)
                .background(Capsule().fill(Color.black.opacity(0.26)))
                .padding(16)
        }
        .shadow(color: Theme.purple.opacity(0.20), radius: 24, x: 0, y: 16)
    }

    private var photoStrip: some View {
        VStack(alignment: .leading, spacing: 10) {
            SectionLabel(text: "选择画面")
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    ForEach(photos) { photo in
                        photoThumb(photo)
                    }
                }
                .padding(.vertical, 5)
            }
        }
    }

    private func photoThumb(_ photo: PuzzlePhoto) -> some View {
        let isSelected = photo.id == selectedPhoto.id
        return Button {
            withAnimation(.spring(response: 0.32, dampingFraction: 0.8)) {
                store.photoIndex = photo.id
            }
            if store.haptics { Haptics.tap() }
        } label: {
            Image(uiImage: PuzzleLibrary.image(for: photo))
                .resizable()
                .aspectRatio(contentMode: .fill)
                .frame(width: 62, height: 62)
                .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
                .overlay(
                    RoundedRectangle(cornerRadius: 18, style: .continuous)
                        .strokeBorder(isSelected ? AnyShapeStyle(Theme.brand)
                                                : AnyShapeStyle(Color.white.opacity(0.7)),
                                      lineWidth: isSelected ? 2.5 : 1)
                )
                .scaleEffect(isSelected ? 1.07 : 1)
                .shadow(color: isSelected ? Theme.pink.opacity(0.32) : Color.clear,
                        radius: 12, x: 0, y: 6)
        }
        .buttonStyle(PressableStyle())
        .accessibilityLabel(photo.name)
    }

    private var difficultySection: some View {
        VStack(alignment: .leading, spacing: 10) {
            SectionLabel(text: "难度")
            HStack(spacing: 6) {
                ForEach(Difficulty.allCases) { item in
                    let isOn = item == difficulty
                    Button {
                        withAnimation(.spring(response: 0.32, dampingFraction: 0.82)) {
                            store.difficulty = item.rawValue
                        }
                        if store.haptics { Haptics.tap() }
                    } label: {
                        VStack(spacing: 3) {
                            Text(item.title)
                                .font(Theme.rounded(16, .bold))
                            Text(item.note)
                                .font(Theme.rounded(11, .medium))
                        }
                        .foregroundColor(isOn ? .white : Theme.subInk)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 12)
                        .background(
                            RoundedRectangle(cornerRadius: 17, style: .continuous)
                                .fill(isOn ? AnyShapeStyle(Theme.brand)
                                           : AnyShapeStyle(Color.clear))
                                .shadow(color: isOn ? Theme.pink.opacity(0.30) : Color.clear,
                                        radius: 10, x: 0, y: 5)
                        )
                    }
                    .buttonStyle(PressableStyle())
                }
            }
            .padding(6)
            .glass(radius: 22)
        }
    }

    private var recordRow: some View {
        HStack(spacing: 10) {
            StatPill(title: "最佳用时", value: Formats.recordTime(record.bestTime))
            StatPill(title: "最少步数", value: record.bestMoves > 0 ? "\(record.bestMoves)" : "--")
            StatPill(title: "完成局数", value: "\(record.plays)")
        }
    }

    private var settingsPanel: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text("偏好设置")
                    .font(Theme.rounded(16, .bold))
                    .foregroundColor(Theme.ink)
                Spacer()
                Button {
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.85)) {
                        showSettings = false
                    }
                } label: {
                    Image(systemName: "xmark")
                        .font(.system(size: 11, weight: .bold))
                        .foregroundColor(Theme.subInk)
                        .frame(width: 26, height: 26)
                        .background(Circle().fill(Color.white.opacity(0.75)))
                }
            }

            ToggleRow(title: "触感反馈", icon: "waveform.path", isOn: $store.haptics)
            ToggleRow(title: "音效", icon: "speaker.wave.2.fill", isOn: $store.sound)
            ToggleRow(title: "显示序号", icon: "number", isOn: $store.showNumbers)
        }
        .padding(18)
        .frame(width: 248)
        .glass(radius: 24)
    }
}
