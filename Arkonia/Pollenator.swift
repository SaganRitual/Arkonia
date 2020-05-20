import SpriteKit

// Remember: everything about pollenators happens during the spritekit scene
// update, so it's ok for us to hit, for example, ArkoniaScene.currentSceneTime,
// unprotected, because it's never changed outside the scene update
class Pollenator {
    var birthday: TimeInterval = 0
    var currentPosition = GridCell.getRandomCell()
    let node = SKShapeNode(circleOfRadius: ArkoniaScene.arkonsPortal.size.hypotenuse / 5)
    let sizeScaleDivisor: TimeInterval
    let speedScaleDivisor: TimeInterval

    var age: TimeInterval { ArkoniaScene.currentSceneTime - birthday }

    init(_ color: SKColor) {
        node.strokeColor = .clear
        node.fillColor = color
        node.alpha = 0.075

        node.zPosition = 1
        node.setScale(1)
        node.position = currentPosition.scenePosition

        ArkoniaScene.arkonsPortal.addChild(node)

        let primes: [TimeInterval] = [3, 5, 7, 11, 13, 17, 19, 23, 29, 31]
        sizeScaleDivisor = primes.randomElement()!
        speedScaleDivisor = primes.randomElement()!

        SceneDispatch.shared.schedule {
            self.birthday = ArkoniaScene.currentSceneTime
            self.move()
        }
    }

    func move() {
        // Vary the scale from 3^1 to 3^-1 over 10-second cycle
        let sizeVariance = sqrt(pow(2, sin(age / sizeScaleDivisor)))
        let sizeScale = CGFloat(sizeVariance) * 0.5
        let speedVariance = sqrt(pow(2, sin(age / speedScaleDivisor)))
        let speedScale = CGFloat(speedVariance) * 100  // in pix/sec

        Debug.log(level: 133) { "pollenator \(sizeScale) \(node.xScale)" }

        let newTarget = GridCell.getRandomCell()
        let distanceToTarget = currentPosition.scenePosition.distance(to: newTarget.scenePosition)
        let travelTime = TimeInterval(distanceToTarget / speedScale)

        currentPosition = newTarget

        let scaleAction = SKAction.scale(to: sizeScale, duration: min(1, travelTime))
        let moveAction = SKAction.move(to: newTarget.scenePosition, duration: travelTime)
        let group = SKAction.group([scaleAction, moveAction])
        node.run(group) { self.move() }
    }
}
