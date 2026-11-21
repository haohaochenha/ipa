import SwiftUI
import UIKit

struct PuzzleBoard: View {
    let board: [Int]
    let size: Int
    let tiles: [Int: UIImage]
    let fullImage: UIImage
    let showsNumbers: Bool
    let showsOriginal: Bool
    var onTap: (Int) -> Void

    private var slots: [Int] { Array(0..<(size * size)) }

    var body: some View {
        GeometryReader { geo in
            let gap: CGFloat = size >= 5 ? 5 : 7
            let side = min(geo.size.width, geo.size.height)
            let cell = (side - gap * CGFloat(size - 1)) / CGFloat(size)
            let originX = (geo.size.width - side) / 2
            let originY = (geo.size.height - side) / 2
            let corner = cell * 0.16

            ZStack(alignment: .topLeading) {
                ForEach(slots, id: \.self) { slot in
                    RoundedRectangle(cornerRadius: corner, style: .continuous)
                        .fill(Color.white.opacity(0.22))
                        .overlay(
                            RoundedRectangle(cornerRadius: corner, style: .continuous)
                                .strokeBorder(Color.white.opacity(0.42), lineWidth: 1)
                        )
                        .frame(width: cell, height: cell)
                        .position(x: originX + CGFloat(slot % size) * (cell + gap) + cell / 2,
                                  y: originY + CGFloat(slot / size) * (cell + gap) + cell / 2)
                }

                ForEach(board, id: \.self) { tileID in
                    if tileID != size * size - 1,
                       let image = tiles[tileID],
                       let slot = board.firstIndex(of: tileID) {
                        tileView(image: image, tileID: tileID, cell: cell, corner: corner)
                            .position(x: originX + CGFloat(slot % size) * (cell + gap) + cell / 2,
                                      y: originY + CGFloat(slot / size) * (cell + gap) + cell / 2)
                    }
                }

                if showsOriginal {
                    Image(uiImage: fullImage)
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: side, height: side)
                        .clipShape(RoundedRectangle(cornerRadius: corner, style: .continuous))
                        .overlay(
                            RoundedRectangle(cornerRadius: corner, style: .continuous)
                                .strokeBorder(Color.white.opacity(0.8), lineWidth: 1)
                        )
                        .position(x: originX + side / 2, y: originY + side / 2)
                        .transition(.opacity)
                }
            }
            .frame(width: geo.size.width, height: geo.size.height)
        }
        .aspectRatio(1, contentMode: .fit)
    }

    private func tileView(image: UIImage, tileID: Int, cell: CGFloat, corner: CGFloat) -> some View {
        ZStack(alignment: .bottomLeading) {
            Image(uiImage: image)
                .resizable()
                .aspectRatio(contentMode: .fill)
                .frame(width: cell, height: cell)
                .clipped()

            if showsNumbers {
                Text("\(tileID + 1)")
                    .font(Theme.rounded(max(10, cell * 0.2), .bold))
                    .foregroundColor(.white)
                    .padding(.horizontal, 5)
                    .padding(.vertical, 2)
                    .background(Capsule().fill(Color.black.opacity(0.35)))
                    .padding(cell * 0.08)
            }
        }
        .frame(width: cell, height: cell)
        .clipShape(RoundedRectangle(cornerRadius: corner, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: corner, style: .continuous)
                .strokeBorder(Color.white.opacity(0.85), lineWidth: 1)
        )
        .shadow(color: Color.black.opacity(0.12), radius: 4, x: 0, y: 2)
        .contentShape(RoundedRectangle(cornerRadius: corner, style: .continuous))
        .onTapGesture { onTap(tileID) }
        .accessibilityLabel("拼图块 \(tileID + 1)")
        .accessibilityAddTraits(.isButton)
    }
}
