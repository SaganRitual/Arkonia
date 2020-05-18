import SpriteKit

class Pollenator {
    var currentPosition = GridCell.getRandomCell()
    var cycleNumber = 0
    let node = SKShapeNode(circleOfRadius: ArkoniaScene.arkonsPortal.size.hypotenuse / 3)
    var scale = CGFloat.zero
    var totalDistance = CGFloat.zero

    init(_ color: SKColor) {
        totalDistance = CGPoint.zero.distance(to: currentPosition.scenePosition)

        node.strokeColor = .clear
        node.fillColor = color
        node.alpha = 0.3

        node.zPosition = 1
        node.setScale(1)
        node.position = currentPosition.scenePosition

        ArkoniaScene.arkonsPortal.addChild(node)

        move()
    }

    func move() {
        defer { cycleNumber += 1 }

        // Start the lilypads off huge, so the arkons can get a foothold
        let baseScale = (cycleNumber == 0) ? 1 : abs(sin(totalDistance)) * 0.25 + 0.05

        Debug.log(level: 133) { "pollenator \(baseScale) \(node.xScale)" }

        let newTarget = GridCell.getRandomCell()
        let distanceToTarget = currentPosition.scenePosition.distance(to: newTarget.scenePosition)
        let speed = CGFloat(100)  // in pix/sec
        let precess = (cycleNumber < 25) ? 1 : abs(sin(CGFloat(cycleNumber) / 10 * (CGFloat.pi / 2))) + 1
        let baseTime = TimeInterval(distanceToTarget / speed)
        let time = baseTime * Double(precess)

        currentPosition = newTarget
        totalDistance += distanceToTarget

        let scaleAction = SKAction.scale(to: baseScale / precess, duration: baseTime)
        let moveAction = SKAction.move(to: newTarget.scenePosition, duration: time)
        let group = SKAction.group([scaleAction, moveAction])
        node.run(group) { self.move() }
    }
}
