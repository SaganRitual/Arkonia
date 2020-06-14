import SpriteKit

// Remember: everything about pollenators happens during the spritekit scene
// update, so it's ok for us to hit, for example, ArkoniaScene.currentSceneTime,
// unprotected, because it's never changed outside the scene update
class Pollenator {
    var birthday: TimeInterval = 0
    var currentPosition = Ingrid.randomCell().scenePosition
    let node = SKShapeNode(circleOfRadius: ArkoniaScene.arkonsPortal.size.hypotenuse / 5)
    let sizePeakToPeak: TimeInterval
    let speedPeakToPeak: TimeInterval

    var age: TimeInterval { ArkoniaScene.currentSceneTime - birthday }

    init(_ color: SKColor) {
        node.strokeColor = .clear
        node.fillColor = color
        node.alpha = 0

        node.zPosition = 1
        node.setScale(1)
        node.position = currentPosition

        ArkoniaScene.arkonsPortal.addChild(node)

        let peakToPeakSeconds: [TimeInterval] = [3, 5, 7, 11, 13]
        sizePeakToPeak = 1 / peakToPeakSeconds.randomElement()!
        speedPeakToPeak = 1 / peakToPeakSeconds.randomElement()!

        SceneDispatch.shared.schedule {
            let s = "\(#line):\(#file)"
            Debug.log(level: 197) { s }
            self.birthday = ArkoniaScene.currentSceneTime
            self.move()
        }
    }

    func move() {
        let positionInSizeCycle = age.truncatingRemainder(dividingBy: sizePeakToPeak) / sizePeakToPeak
        let yInSizeCycle = sin(positionInSizeCycle * TimeInterval.tau)

        let positionInSpeedCycle = age.truncatingRemainder(dividingBy: speedPeakToPeak) / speedPeakToPeak
        let yInSpeedCycle = sin(positionInSpeedCycle * TimeInterval.tau)

        // Nothing special about the functions here; the main thing is the
        // value of the sizeCycleY et al, which is going from 1 to -1
        // periodically. The functions below are pulled out of the air to
        // get the pollenators to move and size according to the whim of
        // the Arkonian deity (you)
        let sizeVariance = sqrt(pow(2, yInSizeCycle))
        let sizeScale = CGFloat(sizeVariance) * 0.5

        let speedVariance = sqrt(pow(2, yInSpeedCycle))
        let speedScale = CGFloat(speedVariance) * 100  // in pix/sec

        Debug.log(level: 133) { "pollenator \(sizeScale) \(node.xScale)" }

        let newTargetPosition = Ingrid.randomCell().scenePosition
        let distanceToTarget = currentPosition.distance(to: newTargetPosition)
        let travelTime = TimeInterval(distanceToTarget / speedScale)

        let scaleAction = SKAction.scale(to: sizeScale, duration: min(1, travelTime))
        let moveAction = SKAction.move(to: newTargetPosition, duration: travelTime)
        let group = SKAction.group([scaleAction, moveAction])

        node.run(group) { self.currentPosition = newTargetPosition; self.move() }
    }
}
