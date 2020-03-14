import SpriteKit

class FertileSpot {
    var distance = CGFloat.zero
    let node = SKShapeNode(circleOfRadius: GriddleScene.arkonsPortal.size.hypotenuse / 3)
    var currentPosition: GridCell

    init() {
        currentPosition = GridCell.getRandomCell()

        node.strokeColor = .clear
        node.alpha = 0
        node.zPosition = 3
        node.position = currentPosition.scenePosition
        GriddleScene.mannaPortal.addChild(node)

        move()
    }

    func move() {
        node.xScale *= 0.90
        node.yScale *= 0.90

        let newTarget = GridCell.getRandomCell()
        let distance = currentPosition.scenePosition.distance(to: newTarget.scenePosition)
        let speed = CGFloat(10)  // in pix/sec
        let time = TimeInterval(distance / speed)

        currentPosition = newTarget

        let action = SKAction.move(to: newTarget.scenePosition, duration: time)
        node.run(action) { self.move() }
    }
}
