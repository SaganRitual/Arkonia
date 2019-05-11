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
        var a0 = Matrix<Double>([sensoryInputs])

        for layer in kNet.hiddenLayers {
            let W = Matrix<Double>(layer.neurons.map { $0.weights })
            let b = Matrix<Double>([layer.neurons.map { $0.bias }])

            let t2 = Surge.mul(W, a0)
            let t3 = Surge.add(t2, b)
            let t4 = t3.joined()
            a0 = Matrix<Double>([t4.map { AFn.function[AFn.FunctionName.sigmoid]!($0) }])
        }

        motorOutputs = kNet.motorLayer.neurons.map { return $0.relay!.output }
        motorOutputs = (0..<a0.rows).map { a0[$0, 0] }

        return true
    }

    func fly(sensoryInputs: [Double]) -> Bool {
        let nodes: [Int] = [12, 16, 16, World.cMotorNeurons]

        guard let nnStructure = try? NeuralNet.Structure(
            nodes: nodes, hiddenActivation: .sigmoid, outputActivation: .softmax
        ) else { preconditionFailure() }

        guard let nn = try? NeuralNet(structure: nnStructure) else { preconditionFailure() }

        guard let m = try? nn.infer(sensoryInputs.map { Float($0) })
            else { preconditionFailure() }

        motorOutputs = m.map { Double($0) }
    }

}
