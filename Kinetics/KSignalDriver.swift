import Foundation
import Surge

class KSignalDriver  {
    static var fishNumber = 0

    var motorLayer: KLayer
    let motorLayerID: KIdentifier
    var motorOutputs: [Double]!
    let senseLayer: KLayer
    let senseLayerID: KIdentifier
    let kNet: KNet

    init(idNumber: Int, fNet: FNet) {
        defer { KSignalDriver.fishNumber += 1 }

        let kNet = KNet.makeNet(idNumber, fNet)

        senseLayerID = kNet.id.add(KIdentifier.KType.senseLayer.rawValue, as: .senseLayer)
        senseLayer = KLayer.makeLayer(
            senseLayerID, KIdentifier.KType.senseLayer, World.cSenseNeurons
        )

        motorLayerID = kNet.id.add(KIdentifier.KType.motorLayer.rawValue, as: .motorLayer)
        motorLayer = KLayer.makeLayer(motorLayerID, KIdentifier.KType.motorLayer, World.cMotorNeurons)

        self.kNet = kNet
    }

    deinit {
//        print("KSignalDriver deinit", kNet.id)
        motorLayer.decoupleFromGrid()
    }

    func drive(sensoryInputs: [Double]) -> Bool {
        if sensoryInputs.isEmpty { return false }

        let neuronCounts = [12, 9, 9, 5]
        var ncSS = 0
        var a0 = Matrix<Double>(sensoryInputs.map { [$0] })

        for _ in 0..<neuronCounts.count - 1 {
            defer { ncSS += 1 }
            let nc0 = neuronCounts[ncSS + 0]
            let nc1 = neuronCounts[ncSS + 1]

            let W = Matrix<Double>((0..<nc1).map { _ in
                (0..<nc0).map { _ in Double.random(in: -10..<10) }
            })

            let b = Matrix<Double>((0..<nc1).map { _ in [Double.random(in: -1.0..<1.0)] })

            let t2 = Surge.mul(W, a0)
            let t3 = Surge.add(t2, b)
            let t4 = t3.joined()
            a0 = Matrix<Double>(t4.map { [AFn.function[AFn.FunctionName.sigmoid]!($0)] })
        }

        motorOutputs = (0..<a0.rows).map { a0[$0, 0] }
        print("mo", motorOutputs!)

        return true
    }

}
