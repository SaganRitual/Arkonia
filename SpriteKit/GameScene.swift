import SpriteKit

// With much gratitude to Jakub Charvat https://www.hackingwithswift.com/users/jakcharvat
// https://www.hackingwithswift.com/forums/swiftui/swiftui-spritekit-macos-catalina-10-15/2662/2669

class GameScene: SKScene, SKSceneDelegate {
    override func didEvaluateActions() {
    }

    override func didMove(to view: SKView) {
        backgroundColor = .black

        view.ignoresSiblingOrder = true
        view.showsFPS = true
        view.showsNodeCount = true
        view.showsDrawCount = true
//        view.isAsynchronous = false
//        view.showsPhysics = true
    }

    override func mouseDown(with event: NSEvent) {
        let location = event.location(in: self)

        let size = CGSize(width: 40, height: 40)
        let cube = SKShapeNode(rectOf: size)
        cube.fillColor = .red
        cube.position = location

        addChild(cube)
    }
}
