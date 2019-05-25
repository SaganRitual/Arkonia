import Cocoa
import Foundation
import SpriteKit

class SceneViewController: NSViewController {

    var scene: SKScene?

    init(frame: NSRect) {
        super.init(nibName: nil, bundle: nil)
        self.view = SKView(frame: frame)
        initializeScene()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        self.view = SKView(frame: self.view.frame)
        initializeScene()
    }

    private func initializeScene() {
        guard let view = view as? SKView else { return }

        view.ignoresSiblingOrder = true
        view.showsFPS = true
        view.showsNodeCount = true
        view.showsDrawCount = true
        //        view.isAsynchronous = false
                view.showsPhysics = true

        let scene = SKScene(fileNamed: "TheScene")!

        self.scene = scene

        // Set the scale mode to scale to fit the window
        scene.scaleMode = .fill
        scene.anchorPoint = CGPoint(x: 0.5, y: 0.5)

        view.presentScene(scene)
    }

}
