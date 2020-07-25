struct NetStructure {
    static let cSenseRingsRange: ClosedRange<Int> = 1...10

    let layerDescriptors: [Int]

    let cHiddenNeurons: Int
    let cMotorNeurons: Int
    let cSenseNeurons: Int

    let cBiases: Int
    let cNeurons: Int
    let cWeights: Int

    let sensorPadCCells: Int
    let cSenseRings: Int

    let cSenseNeuronsGrid: Int
    let cSenseNeuronsPollenators: Int
    let cSenseNeuronsMisc: Int

    var isCloneOfParent = false

    init(_ cSenseRings: Int?, _ parentLayerDescriptors: [Int]?) {
        self.cSenseRings = cSenseRings ??  Int.random(in: NetStructure.cSenseRingsRange)
        self.sensorPadCCells = GridIndexer.cellsWithinSenseRange(self.cSenseRings)
//        self.layerDescriptors = NetStructure.layerStructures[self.cSenseRings]!.randomElement()!

        self.cSenseNeuronsMisc = DriveStimulus.MiscSenses.allCases.count
        self.cSenseNeuronsPollenators = Arkonia.cPollenators * 2
        self.cSenseNeuronsGrid = self.sensorPadCCells * 2
        self.cSenseNeurons = cSenseNeuronsMisc + cSenseNeuronsPollenators + cSenseNeuronsGrid

        self.cMotorNeurons = DriveResponse.MotorIndex.allCases.count

        self.layerDescriptors =
            NetStructure.buildLayerStructure(cSenseNeurons, cMotorNeurons)

        // There must be at least one hidden layer
        hardAssert(self.layerDescriptors.count >= 3) { nil }

        self.cHiddenNeurons = self.layerDescriptors.dropFirst().dropLast().reduce(0, +)

        let debugCNeurons = cSenseNeurons + cHiddenNeurons + cMotorNeurons

        // This ugliness is just so I can compare the layer structure
        // to the parent layer structure; I'm feeling too lazy to think
        // about how to make it into an if/let construct
        let layerStructureIsClone = (self.layerDescriptors == parentLayerDescriptors)

        (self.cNeurons, self.cBiases, self.cWeights) =
            NetStructure.computeNetParameters(layerDescriptors)

        Debug.log(level: 217) { "cSenseRings \(self.cSenseRings)" }

        hardAssert(debugCNeurons == cNeurons) { "\(#line) in \(#file)" }

        let cp = layerStructureIsClone && (self.cSenseRings == cSenseRings)

        Debug.log(level: 218) { "layerDescriptors -> \(layerDescriptors)" }

        isCloneOfParent = cp
    }

    // swiftlint:disable large_tuple
    // Large Tuple Violation: Tuples should have at most 2 members
    static func computeNetParameters(_ layerDescriptors: [Int]) -> (Int, Int, Int) {
        let dd = layerDescriptors

        let cNeurons = dd.reduce(0, +)
        let cBiases  = dd.dropFirst().reduce(0, +)
        let cWeights = zip(dd.dropLast(), dd.dropFirst()).reduce(0) { $0 + ($1.0 * $1.1) }

        return (cNeurons, cBiases, cWeights)
    }
    // swiftlint:enable large_tuple
}

extension NetStructure {
    static func buildLayerStructure(_ cSenseNeurons: Int, _ cMotorNeurons: Int) -> [Int] {
        var layerStructure = [cSenseNeurons]
//        var randomer = AKRandomer(.uniform)

        var cMaxNeuronsThisLayer = cSenseNeurons
        Debug.log(level: 217) { "cSenseNeurons \(cSenseNeurons)"}

        // Try to make each layer at least half the size of the layer above it
        while cMaxNeuronsThisLayer > (cMotorNeurons * 4) {
//            let divisor = randomer.inRange(2..<(cMaxNeuronsThisLayer / (cMotorNeurons * 2)))
            let divisor = 2
            Debug.log(level: 217) { "divisor \(divisor)"}
            if divisor == 0 { break }

            let cNeuronsThisLayer = cMaxNeuronsThisLayer / divisor
            layerStructure.append(cNeuronsThisLayer)

            Debug.log(level: 217) {
                "cn \(cMaxNeuronsThisLayer)"
                + ", \(divisor)"
                + ", \(cNeuronsThisLayer)"
                + " -> \(cMaxNeuronsThisLayer - (cNeuronsThisLayer * divisor))"
            }

            cMaxNeuronsThisLayer -= cNeuronsThisLayer
        }

        layerStructure.append(cMotorNeurons)

        Debug.log(level: 217) { "buildLayerStructure -> \(layerStructure)" }

        return layerStructure
    }
}
