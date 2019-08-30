import Foundation
import SpriteKit

enum ActionPrimitive: Comparable, Hashable {
    case go

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
        let joulesNeeded = abs(targetAVelocity) * arkon.physicsBody!.mass     // By fiat, energy needed is a function of the speed
        let sign = abs(torqueIndex) / torqueIndex

        return SKAction.run {
//            let impulse = sign * self.energySource.withdrawFromReady(joulesNeeded)

//            print(
//                "[rotate   ",
//                String(format: "% 6.2f ", arkon.arkon.metabolism.stomach.level),
//                String(format: "% 6.2f ", arkon.arkon.metabolism.readyEnergyReserves.level),
//                String(format: "% 6.2f ", arkon.arkon.metabolism.fatReserves.level),
//                String(format: "% 6.2f ", arkon.arkon.metabolism.spawnReserves.level),
//                String(format: "% 6.2f ", arkon.arkon.metabolism.energyContent)
//            )

//            arkon.physicsBody!.applyAngularImpulse(impulse)

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

    func getThrustAction(_ arkon: SKSpriteNode, _ thrustIndex: CGFloat) -> SKAction {
        let fudgeFactor: CGFloat = 0.8
        let targetSpeed: CGFloat = thrustIndex * 1000  // 1000 pixels/sec (ish)
        let joulesNeeded = fudgeFactor * abs(targetSpeed) * arkon.physicsBody!.mass

        return SKAction.run {

//            print(
//                "[thrust   ",
//                String(format: "% 6.2f ", arkon.arkon.metabolism.stomach.level),
//                String(format: "% 6.2f ", arkon.arkon.metabolism.readyEnergyReserves.level),
//                String(format: "% 6.2f ", arkon.arkon.metabolism.fatReserves.level),
//                String(format: "% 6.2f ", arkon.arkon.metabolism.spawnReserves.level),
//                String(format: "% 6.2f ", arkon.arkon.metabolism.energyContent)
//            )

            let impulse = self.energySource.withdrawFromReady(joulesNeeded)

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

//        print("d", oxygenLevel)
        }
    }

    func getWaitAction(_ duration: CGFloat) -> SKAction {
        let conversion = capCheck(TimeInterval(abs(duration)))
        return SKAction.wait(forDuration: conversion)
    }

    //swiftmint:disable cyclomatic_complexity
    func selectActionPrimitive(sprite: SKSpriteNode, motorOutputs: [Double]) -> SKAction {

        let m = motorOutputs
//        let selector = CGFloat(Int(m.removeFirst() * 100.0)) / 100.0
        let primitive: ActionPrimitive

        switch sprite.karamba.motionSelector % 3 {
        case 0:  primitive = .goThrust(CGFloat(m[0] * m[2]))
        case 1:  primitive = .goWait(CGFloat(m[3]) / 10)
        case 2:  primitive = .goRotate(CGFloat(m[1]) / 10)
        default: preconditionFailure()
        }

        sprite.karamba.motionSelector += 1

        switch primitive {
        case let .goRotate(torqueIndex):  return getRotateAction(sprite, torqueIndex)
        case let .goThrust(thrustIndex):  return getThrustAction(sprite, thrustIndex)
        case let .goWait(duration):       return getWaitAction(duration)
        }
    }
    //swiftmint:enable cyclomatic_complexity

}
