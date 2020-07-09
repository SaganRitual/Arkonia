import SpriteKit
import SwiftUI

// With much gratitude to Jakub Charvat https://www.hackingwithswift.com/users/jakcharvat
// https://www.hackingwithswift.com/forums/swiftui/swiftui-spritekit-macos-catalina-10-15/2662/2669

struct GameView: View {
    let scene: SKScene

    var body: some View {
        GeometryReader { proxy in
            GameViewRepresentable(scene: scene, proxy: proxy)
        }
    }
}

struct GameViewRepresentable: NSViewRepresentable {
    let scene: SKScene
    let proxy: GeometryProxy

    func makeCoordinator() -> Coordinator {
        Coordinator()
    }

    func makeNSView(context: Context) -> SKView {
        scene.size = proxy.size
        context.coordinator.scene = scene

        // Set the scale mode to scale to fit the window
        scene.scaleMode = .fill
        scene.anchorPoint = CGPoint(x: 0.5, y: 0.5)

        let view = SKView()
        view.presentScene(scene)
        return view
    }

    func updateNSView(_ nsView: SKView, context: Context) {
        context.coordinator.resizeScene(proxy: proxy)
    }

    class Coordinator: NSObject {
        weak var scene: SKScene?

        func resizeScene(proxy: GeometryProxy) {
            scene?.size = proxy.size
        }
    }
}
