import Foundation

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
        var message = "sensoryInputs \(self.kNet): " +
                        "cRelays = \(senseLayer.signalRelays.count), " +
                        "non-nil = \(senseLayer.signalRelays.map { $0.inputRelays.count })"

        for (sensoryInput, relay) in zip(sensoryInputs, senseLayer.signalRelays) {
            relay.overrideState(operational: true)
            relay.output = sensoryInput
            message += ", \(sensoryInput)"
        }

//        Log.L.write("\(message)\n")

        let arkonSurvived = kNet.driveSignal(senseLayer, motorLayer)
        if !arkonSurvived { return false }

        motorOutputs = kNet.motorLayer.neurons.map { return $0.relay!.output }
//        Log.L.write("motorOutputs \(self.kNet): \(motorOutputs!)\n")

        return true
    }
}
