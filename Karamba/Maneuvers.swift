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

protocol ManeuverProtocol {
    var scene: SKScene { get }

    func execute(arkon: Karamba, motorOutputs: [Double])
    func goSprite(arkon: Karamba, motorOutputs: [Double])
    func selectActionPrimitive(arkon: Karamba, motorOutputs: [Double]) -> SKAction
}

protocol LinearManeuverProtocol: ManeuverProtocol {
    func calculateForceVector(sprite sprite_: SKNode) -> CGVector
}

protocol AngularManeuverProtocol: ManeuverProtocol {
    func calculateAngularForce(spriteSS: Int) -> CGFloat
}

extension ManeuverProtocol {

    func execute(arkon: Karamba, motorOutputs: [Double]) {
        goSprite(arkon: arkon, motorOutputs: motorOutputs)
    }

    func goSprite(arkon: Karamba, motorOutputs: [Double]) {
        let primitive = selectActionPrimitive(arkon: arkon, motorOutputs: motorOutputs)
        arkon.run(primitive)
    }

    func capCheck<T: BinaryFloatingPoint>(_ value: T) -> T {
        if value >= -1 && value <= 1 { return value }
        print("capCheck: \(value)")
//        assert(false)
        return constrain(value, lo: -1, hi: 1)
    }

    func selectActionPrimitive(arkon: Karamba, motorOutputs: [Double]) -> SKAction {

        var m = motorOutputs
        let power = CGFloat(m.removeFirst())
        let primitives: [ActionPrimitive] = [
            .goFullStop, .goThrust(power), .goRotate(power), .goWait(power)
        ]

        let tagged: [(ActionPrimitive, Double)] = zip(primitives, m).map {($0, $1)}

        let sorted = tagged.sorted { lhs, rhs in
            if lhs.1 == rhs.1 { return Bool.random() }
            return (abs(lhs.1) < abs(rhs.1))
        }

        let maxEntry = hardBind(sorted.last)

        switch maxEntry.0 {
        case .goFullStop:
            return SKAction.run {
                arkon.pBody.velocity = CGVector.zero
                arkon.pBody.angularVelocity = 0
//                arkon.color = .red
//                arkon.nose.color = .red
            }

        case let .goRotate(torqueIndex):    // -1.0..<1.0 == -(tau rev/s)..<(tau rev/s)
            let targetAVelocity = torqueIndex / CGFloat.tau
            let impulseConstant: CGFloat = 1.1 / 2
            let impulse = arkon.pBody.mass * targetAVelocity * impulseConstant

            let cost = abs(torqueIndex) * arkon.pBody.mass / 120

//            arkon.color = .yellow
//            arkon.nose.color = .yellow

            arkon.metabolism.debitEnergy(cost)
//            print("Rotate mass \(arkon.pBody.mass) power \(power), impulse \(impulse), cost per frame \(cost)")
//            if power > 0 {
//                print("\(arkon.pBody.mass)")
//                print("fuck")
//            }
            return SKAction.run { arkon.pBody.applyAngularImpulse(impulse) }

        case let .goThrust(power):
//            print("Thrust \(power)")
            arkon.metabolism.debitEnergy(abs(power) / 10)
//            arkon.color = .orange
//            arkon.nose.color = .orange
            let p = capCheck(power)
            let vector = CGVector(radius: abs(p), theta: arkon.zRotation)
            return SKAction.run { arkon.pBody.applyImpulse(vector) }

        case let .goWait(duration):
//            print("Wait \(abs(duration) * 10.0 / 60.0)")
            let conversion = capCheck(TimeInterval(abs(duration)))
//            arkon.color = .cyan
//            arkon.nose.color = .cyan
            return SKAction.wait(forDuration: conversion)
        }
    }
}
