import SwiftUI

@main
struct NineGridPuzzleApp: App {
    @StateObject private var store = GameStore()

    var body: some Scene {
        WindowGroup {
            RootView(store: store)
                .preferredColorScheme(.light)
        }
    }
}

struct GameSession: Identifiable {
    let id = UUID()
    let photo: PuzzlePhoto
    let difficulty: Difficulty
}

struct RootView: View {
    @ObservedObject var store: GameStore
    @State private var session: GameSession?

    var body: some View {
        ZStack {
            AuroraBackground()

            if let session = session {
                GameView(photo: session.photo,
                         difficulty: session.difficulty,
                         store: store,
                         onExit: { closeSession() })
                    .id(session.id)
                    .transition(.asymmetric(insertion: .move(edge: .trailing).combined(with: .opacity),
                                            removal: .move(edge: .trailing).combined(with: .opacity)))
            } else {
                HomeView(store: store) { photo, difficulty in
                    withAnimation(.spring(response: 0.45, dampingFraction: 0.86)) {
                        session = GameSession(photo: photo, difficulty: difficulty)
                    }
                }
                .transition(.asymmetric(insertion: .move(edge: .leading).combined(with: .opacity),
                                        removal: .move(edge: .leading).combined(with: .opacity)))
            }
        }
    }

    private func closeSession() {
        withAnimation(.spring(response: 0.4, dampingFraction: 0.86)) {
            session = nil
        }
    }
}
