import SpriteKit

class FertileSpot {
    var distance = CGFloat.zero
    let node = SKShapeNode(circleOfRadius: GriddleScene.arkonsPortal.size.hypotenuse / 1.5)
    var currentPosition: GridCell

    init() {
        currentPosition = GridCell.getRandomCell()

        node.position = currentPosition.scenePosition
        node.zPosition = 100
        GriddleScene.arkonsPortal.addChild(node)

        move()
    }

    func move() {
        node.xScale *= 0.99
        node.yScale *= 0.99

        let newTarget = GridCell.getRandomCell()
        let distance = currentPosition.scenePosition.distance(to: newTarget.scenePosition)
        let speed = CGFloat(100)  // in pix/sec
        let time = TimeInterval(distance / speed)

        currentPosition = newTarget

        let action = SKAction.move(to: newTarget.scenePosition, duration: time)
        node.run(action) { self.move() }
    }
}
