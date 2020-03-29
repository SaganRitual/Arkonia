import SpriteKit

class Pollenator {
    var currentPosition = GridCell.at(AKPoint.zero)
    var firstPass = true
    let node = SKShapeNode(circleOfRadius: GriddleScene.arkonsPortal.size.hypotenuse / 3)
    var scale = CGFloat.zero
    var totalDistance = CGFloat.zero

    init(_ color: SKColor) {
        totalDistance = CGPoint.zero.distance(to: currentPosition.scenePosition)

        node.strokeColor = color   // Set to .white to see it on screen, for debug
        node.fillColor = .clear
        node.alpha = 0
        node.zPosition = 5
        node.setScale(10)
        node.position = currentPosition.scenePosition
        GriddleScene.mannaPortal.addChild(node)

        move()
    }

    func move() {
        // Start the lilypads off huge, so the arkons can get a foothold
        let scale = firstPass ? 10 : abs(sin(totalDistance)) * 0.25 + 0.1
        firstPass = false

        Debug.log(level: 133) { "pollenator \(scale) \(node.xScale)" }

        let newTarget = GridCell.getRandomCell()
        let distanceToTarget = currentPosition.scenePosition.distance(to: newTarget.scenePosition)
        let speed = CGFloat(100)  // in pix/sec
        let time = TimeInterval(distanceToTarget / speed)

        currentPosition = newTarget
        totalDistance += distanceToTarget

        let scaleAction = SKAction.scale(to: scale, duration: time)
        let moveAction = SKAction.move(to: newTarget.scenePosition, duration: time)
        let group = SKAction.group([scaleAction, moveAction])
        node.run(group) { self.move() }
    }
}
