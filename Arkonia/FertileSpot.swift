import SpriteKit

class FertileSpot {
    var currentPosition: GridCell
    let node = SKShapeNode(circleOfRadius: GriddleScene.arkonsPortal.size.hypotenuse / 3)
    var scale = CGFloat.zero
    var totalDistance = CGFloat.zero

    init() {
        currentPosition = GridCell.getRandomCell()
        totalDistance = CGPoint.zero.distance(to: currentPosition.scenePosition)

        node.strokeColor = .white   // Set to .white to see it on screen, for debug
        node.alpha = 1
        node.zPosition = 5
        node.position = currentPosition.scenePosition
        GriddleScene.mannaPortal.addChild(node)

        move()
    }

    func move() {
        let scale = abs(sin(totalDistance)) * 0.25 + 0.1

        Debug.log(level: 133) { "fertile \(scale) \(node.xScale)" }

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
