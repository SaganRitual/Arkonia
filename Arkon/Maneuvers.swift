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
    let energySource: EnergySourceProtocol

    init(energySource: EnergySourceProtocol) { self.energySource = energySource }

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

    func getRotateAction(_ arkon: SKSpriteNode, _ torqueIndex: CGFloat) -> SKAction {
        // -1.0..<1.0 == -(2pi rev/s)..<(2pi rev/s)

        let fudgeFactor: CGFloat = 1.15
        let piRevsPerSecond: CGFloat = 2.0
        let targetAVelocity = fudgeFactor * piRevsPerSecond * torqueIndex / (3 * CGFloat.tau)
        let joulesNeeded = targetAVelocity * arkon.physicsBody!.mass     // By fiat, energy needed is a function of the speed

        return SKAction.run {
            let energyPacket = self.energySource.retrieveEnergy(joulesNeeded)
            let impulse = energyPacket.energyContent

//            print(
//                "[rotate   ",
//                String(format: "% 6.2f ", arkon.arkon.metabolism.stomach.level),
//                String(format: "% 6.2f ", arkon.arkon.metabolism.readyEnergyReserves.level),
//                String(format: "% 6.2f ", arkon.arkon.metabolism.fatReserves.level),
//                String(format: "% 6.2f ", arkon.arkon.metabolism.spawnReserves.level),
//                String(format: "% 6.2f ", arkon.arkon.metabolism.energyContent)
//            )

            arkon.physicsBody!.applyAngularImpulse(impulse)
            _ = self.energySource.expendEnergy(energyPacket)

//            print(
//                "rotate   ",
//                String(format: "% 6.2f ", arkon.arkon.metabolism.stomach.level),
//                String(format: "% 6.2f ", arkon.arkon.metabolism.readyEnergyReserves.level),
//                String(format: "% 6.2f ", arkon.arkon.metabolism.fatReserves.level),
//                String(format: "% 6.2f ", arkon.arkon.metabolism.spawnReserves.level),
//                String(format: "% 6.2f\n]", arkon.arkon.metabolism.energyContent)
//            )
        }
    }

    func getStopAction(_ arkon: SKSpriteNode) -> SKAction {
        return SKAction.run {
            arkon.physicsBody!.velocity = CGVector.zero
            arkon.physicsBody!.angularVelocity = 0

            let nosePhysicsBody = (arkon.children[0] as? SKSpriteNode)!.physicsBody
            nosePhysicsBody!.velocity = CGVector.zero
            nosePhysicsBody!.angularVelocity = 0
        }
    }

    func getThrustAction(_ arkon: SKSpriteNode, _ thrustIndex: CGFloat) -> SKAction {
        let fudgeFactor: CGFloat = 0.8
        let targetSpeed: CGFloat = thrustIndex * 1000  // 1000 pixels/sec (ish)
        let joulesNeeded = fudgeFactor * targetSpeed * arkon.physicsBody!.mass

        return SKAction.run {

//            print(
//                "[thrust   ",
//                String(format: "% 6.2f ", arkon.arkon.metabolism.stomach.level),
//                String(format: "% 6.2f ", arkon.arkon.metabolism.readyEnergyReserves.level),
//                String(format: "% 6.2f ", arkon.arkon.metabolism.fatReserves.level),
//                String(format: "% 6.2f ", arkon.arkon.metabolism.spawnReserves.level),
//                String(format: "% 6.2f ", arkon.arkon.metabolism.energyContent)
//            )

            let energyPacket = self.energySource.retrieveEnergy(joulesNeeded)
            let impulse = energyPacket.energyContent

            let vector = CGVector(radius: impulse, theta: arkon.zRotation)

//            print(
//                "thrust   ",
//                String(format: "% 6.2f ", arkon.arkon.metabolism.stomach.level),
//                String(format: "% 6.2f ", arkon.arkon.metabolism.readyEnergyReserves.level),
//                String(format: "% 6.2f ", arkon.arkon.metabolism.fatReserves.level),
//                String(format: "% 6.2f ", arkon.arkon.metabolism.spawnReserves.level),
//                String(format: "% 6.2f\n]", arkon.arkon.metabolism.energyContent)
//            )

            arkon.physicsBody!.applyImpulse(vector)
            _ = self.energySource.expendEnergy(energyPacket)
        }
    }

    func getWaitAction(_ duration: CGFloat) -> SKAction {
        let conversion = capCheck(TimeInterval(abs(duration)))
        return SKAction.wait(forDuration: conversion)
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
        case .goFullStop:                 return getStopAction(arkon)
        case let .goRotate(torqueIndex):  return getRotateAction(arkon, torqueIndex)
        case let .goThrust(thrustIndex):  return getThrustAction(arkon, thrustIndex)
        case let .goWait(duration):       return getWaitAction(duration)
        }
    }

}

extension Maneuvers {
    struct DummyEnergyPacket: EnergyPacketProtocol {
        let energyContent: CGFloat
    }

    struct EnergySource: EnergySourceProtocol {
        func expendEnergy(_ packet: EnergyPacketProtocol) -> CGFloat { return packet.energyContent }
        func retrieveEnergy(_ cJoules: CGFloat) -> EnergyPacketProtocol {
            return DummyEnergyPacket(energyContent: cJoules)
        }
    }

    static var tenPass = 0

    static func getActions(sprite: SKSpriteNode) -> SKAction {
        let maneuvers = Maneuvers(energySource: EnergySource())
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
        let preWait = SKAction.wait(forDuration: 5.0)
        let sequence = SKAction.sequence([preWait, actions])
        sprite.run(sequence) { onePass(sprite: sprite) }
    }

    static func selfTest(background: SKSpriteNode, scene: SKScene) {
        let sprite = SpriteFactory(scene: scene).arkonsHangar.makeSprite()
        sprite.setScale(0.5)

        background.addChild(sprite)

        sprite.physicsBody = SKPhysicsBody(circleOfRadius: sprite.size.width / 2)
        sprite.physicsBody!.mass = 1
        onePass(sprite: sprite)

//        print("oass", sprite.physicsBody!.mass)//, nose.physicsBody!.mass)
    }
}
