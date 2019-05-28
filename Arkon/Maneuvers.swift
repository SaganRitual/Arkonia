import Foundation
import SpriteKit

enum ActionPrimitive: Comparable, Hashable {
    case goFullStop
    case goRotate(CGFloat)
    case goThrust(CGFloat)
    case goWait(CGFloat)

    static func < (_ lhs: ActionPrimitive, _ rhs: ActionPrimitive) -> Bool {
        switch (lhs, rhs) {
        case (.goWait, _): return false

        case (_, .goFullStop): return false
        case (.goFullStop, _): return true

        case (.goThrust, .goWait): return true
        case (.goThrust, _): return false

        case (.goRotate, .goWait): return true
        case (.goRotate, .goThrust): return true
        case (.goRotate, _): return false
        }
    }
}

struct Maneuvers {

    func execute(arkon: SKSpriteNode, motorOutputs: [Double]) {
        goSprite(arkon: arkon, motorOutputs: motorOutputs)
    }

    func goSprite(arkon: SKSpriteNode, motorOutputs: [Double]) {
        let primitive = selectActionPrimitive(arkon: arkon, motorOutputs: motorOutputs)
        arkon.run(primitive)
    }

    func capCheck<T: BinaryFloatingPoint>(_ value: T) -> T {
        if value >= -1 && value <= 1 { return value }
        print("capCheck: \(value)")
        //        assert(false)
        return constrain(value, lo: -1, hi: 1)
    }

    func selectActionPrimitive(arkon: SKSpriteNode, motorOutputs: [Double]) -> SKAction {

        var m = motorOutputs
        let power = CGFloat(Int(m.removeFirst() * 100.0)) / 100.0
        let primitives: [ActionPrimitive] = [
            .goFullStop, .goThrust(power), .goRotate(power), .goWait(power)
        ]

        let tagged: [(ActionPrimitive, Double)] = zip(primitives, m).map {($0, $1)}

        let sorted = tagged.sorted { lhs, rhs in
            return (abs(lhs.1) < abs(rhs.1))
        }

        let maxEntry = sorted.last!

        switch maxEntry.0 {
        case .goFullStop:
            return SKAction.run {
                arkon.physicsBody!.velocity = CGVector.zero
                arkon.physicsBody!.angularVelocity = 0
            }

        case let .goRotate(torqueIndex):    // -1.0..<1.0 == -(pi rev/s)..<(pi rev/s)
            let fudgeFactor: CGFloat = 1.1
            let targetAVelocity = torqueIndex * CGFloat.pi * fudgeFactor
            let impulse = targetAVelocity / (3 * CGFloat.tau)

            return SKAction.run { arkon.physicsBody!.applyAngularImpulse(impulse) }

        case let .goThrust(thrustIndex_):
            let thrustIndex = capCheck(thrustIndex_)
            let impulse: CGFloat = thrustIndex * 500    // pixels/sec (ish)

            let vector = CGVector(radius: impulse, theta: arkon.zRotation)

            return SKAction.run { arkon.physicsBody!.applyImpulse(vector) }

        case let .goWait(duration):
            let conversion = capCheck(TimeInterval(abs(duration)))
            return SKAction.wait(forDuration: conversion)
        }
    }

}

extension Maneuvers {
    static var tenPass = 0

    static func getActions(sprite: SKSpriteNode) -> SKAction {
        let maneuvers = Maneuvers()
        let actions = SKAction.sequence([
            maneuvers.selectActionPrimitive(arkon: sprite, motorOutputs: [1, 0, 1, 0, 0]),  // thrust
            maneuvers.selectActionPrimitive(arkon: sprite, motorOutputs: [1, 0, 0, 0, 1]),  // wait
            maneuvers.selectActionPrimitive(arkon: sprite, motorOutputs: [1, 1, 0, 0, 0]),  // stop
            maneuvers.selectActionPrimitive(arkon: sprite, motorOutputs: [1, 0, 0, 0, 1]),  // wait
            maneuvers.selectActionPrimitive(arkon: sprite, motorOutputs: [1, 0, 0, 1, 0]),  // rotate
            maneuvers.selectActionPrimitive(arkon: sprite, motorOutputs: [1, 0, 0, 0, 1]),  // wait
            maneuvers.selectActionPrimitive(arkon: sprite, motorOutputs: [1, 1, 0, 0, 0]),  // stop
            maneuvers.selectActionPrimitive(arkon: sprite, motorOutputs: [1, 0, 0, 0, 1])   // wait
        ])

        return actions
    }

    static func onePass(sprite: SKSpriteNode) {
        if tenPass >= 10 { return }
        tenPass += 1

        let actions = getActions(sprite: sprite)
        sprite.run(actions) { onePass(sprite: sprite) }
    }

    static func selfTest(background: SKSpriteNode, scene: SKScene) {
        let sprite = SpriteFactory(scene: scene).arkonsHangar.makeSprite()
        background.addChild(sprite)

        sprite.physicsBody = SKPhysicsBody(circleOfRadius: sprite.size.width / 2)
        sprite.physicsBody!.mass = 1
        sprite.setScale(0.5)
        onePass(sprite: sprite)
    }
}
