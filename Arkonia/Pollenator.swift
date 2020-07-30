import SpriteKit

// Remember: everything about pollenators happens during the spritekit scene
// update, so it's ok for us to hit, for example, ArkoniaScene.currentSceneTime,
// unprotected, because it's never changed outside the scene update
class Pollenator {
    var birthday: TimeInterval = 0
    var currentPosition = Grid.randomCell().properties.scenePosition
    let node = SKShapeNode(circleOfRadius: ArkoniaScene.arkonsPortal.size.hypotenuse / 5)
    let sizePeakToPeak: TimeInterval
    let speedPeakToPeak: TimeInterval
    var temperatureAdjustment: CGFloat = 0

    var age: TimeInterval { ArkoniaScene.currentSceneTime - birthday }

    init(_ color: SKColor) {
        node.strokeColor = color
        node.fillColor = color
        node.alpha = 0.1

        node.zPosition = 1
        node.setScale(1)
        node.position = currentPosition

        ArkoniaScene.arkonsPortal.addChild(node)

        sizePeakToPeak = 1 / TimeInterval.random(in: 3..<15)
        speedPeakToPeak = 1 / TimeInterval.random(in: 3..<15)

        self.birthday = ArkoniaScene.currentSceneTime

        move()
    }

    func getTemperature(_ onComplete: @escaping () -> Void) {
        Clock.dispatchQueue.async {
            let t = Clock.shared.seasonalFactors.temperatureCurve
            self.temperatureAdjustment = (t + 2) / 2  // Scale -1..<1 to 1..<2
            Debug.log(level: 217) { "pollenator? \(t) \(self.temperatureAdjustment)" }
            onComplete()
        }
    }

    func move() { getTemperature(move_B) }

    func move_B() { SceneDispatch.shared.schedule("move_b", move_C) }

    func move_C() {

        let sizePeakToPeak = 1 / TimeInterval.random(in: 10..<20)
        let speedPeakToPeak = 1 / TimeInterval.random(in: 10..<20)

        let positionInSizeCycle = age.truncatingRemainder(dividingBy: sizePeakToPeak) / sizePeakToPeak
        let positionInSpeedCycle = age.truncatingRemainder(dividingBy: speedPeakToPeak) / speedPeakToPeak

        let yInSizeCycle = sin(positionInSizeCycle * TimeInterval.tau)
        let yInSpeedCycle = sin(positionInSpeedCycle * TimeInterval.tau)

        // Nothing special about the functions here; the main thing is the
        // value of the sizeCycleY et al, which is going from 1 to -1
        // periodically. The functions below are pulled out of the air to
        // get the pollenators to move and size according to the whim of
        // the Arkonian deity
        let sizeVariance = sqrt(pow(2, yInSizeCycle))
        let sizeFudgeFactor: CGFloat = 0.3
        let sizeScale = CGFloat(sizeVariance) * sizeFudgeFactor * temperatureAdjustment

        let speedVariance = sqrt(pow(2, yInSpeedCycle))
        let speedFudgeFactor: CGFloat = 50.0
        let speedScale = CGFloat(speedVariance) * speedFudgeFactor * temperatureAdjustment  // in pix/sec

        Debug.log(level: 217) { "pollenator \(sizeScale) \(speedScale)" }

        let newTargetPosition = Grid.randomCell().properties.scenePosition
        let distanceToTarget = currentPosition.distance(to: newTargetPosition)
        let travelTime = TimeInterval(distanceToTarget / speedScale)

        let scaleAction = SKAction.scale(to: sizeScale, duration: min(1, travelTime))
        let moveAction = SKAction.move(to: newTargetPosition, duration: travelTime)
        let group = SKAction.group([scaleAction, moveAction])

        node.run(group) {
            self.currentPosition = newTargetPosition
            self.move()
        }
    }
}
