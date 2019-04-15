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

    func selectActionPrimitive(arkon: Karamba, motorOutputs: [Double]) -> SKAction {

        var m = motorOutputs
        let power = CGFloat(m.removeFirst())

        let primitives: [ActionPrimitive] = [.goFullStop, .goThrust(power), .goRotate(power), .goWait(power)]
        let tagged: [ActionPrimitive: Double] = zip(primitives, m).reduce([:]) {
            var dictionary = $0
            dictionary[$1.0] = $1.1
            return dictionary
        }

        let sorted = tagged.sorted { lhs, rhs in
            let inertia = (lhs.key == arkon.mostRecentAction) ?
                (0.1 * lhs.value / abs(lhs.value)) : 0.0

            return abs(lhs.value + inertia) < abs(rhs.value)
        }

        let maxEntry = hardBind(sorted.last)

//        if arkon.scab.fishNumber == 0 {
//            print("actions for \(arkon.scab.fishNumber): ", terminator: "")
//            sorted.forEach { print($0, terminator: "") }
//            print("; chose", maxEntry.key, "over", arkon.mostRecentAction)
//        }

        defer { arkon.mostRecentAction = maxEntry.key }

        switch maxEntry.key {
        case .goFullStop:
            return SKAction.run {
                arkon.pBody.velocity = CGVector.zero
                arkon.pBody.angularVelocity = 0
            }

        case let .goRotate(power):
            arkon.metabolism.debitEnergy(abs(power) / 100)
            return SKAction.run { arkon.pBody.applyAngularImpulse(power / 100) }

        case let .goThrust(power):
            arkon.metabolism.debitEnergy(abs(power) / 1000)
            let vector = CGVector(radius: abs(power) * 100, theta: arkon.zRotation)
            return SKAction.run { arkon.pBody.applyImpulse(vector) }

        case let .goWait(duration):
            let conversion = TimeInterval(abs(duration) * 10.0 / 60.0)
            return SKAction.wait(forDuration: conversion)
        }
    }
}
