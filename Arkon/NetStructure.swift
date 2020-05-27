enum MiscSenses: Int, CaseIterable {
    case x, y, hunger, asphyxiation
    case gestationFullness, dayFullness, yearFullness
}

enum MotorNeurons: Int, CaseIterable {
    case jumpTarget, jumpSpeed
}

struct NetStructure {
    static let cLayersRange: ClosedRange<Int> = 2...5
    static let cSenseRingsRange: ClosedRange<Int> = 1...10

    let layerDescriptors: [Int]

    let cMotorOutputs: Int
    let cSenseInputs: Int

    let cBiases: Int
    let cNeurons: Int
    let cWeights: Int

    let cCellsWithinSenseRange: Int
    let cSenseRings: Int

    let cSenseInputsFromGrid: Int
    let cSenseInputsFromPollenators: Int
    let cSenseInputsMisc: Int

    var isCloneOfParent = false

    init(_ cSenseRings: Int?, _ parentLayerDescriptors: [Int]?) {
        self.cSenseRings = cSenseRings ?? Int.random(in: NetStructure.cSenseRingsRange)

        let cCellsPerSide = 1 + 2 * self.cSenseRings
        self.cCellsWithinSenseRange = cCellsPerSide * cCellsPerSide

        self.cSenseInputsFromGrid = cCellsWithinSenseRange * 2
        self.cSenseInputsMisc = MiscSenses.allCases.count
        self.cSenseInputsFromPollenators = Arkonia.cPollenators * 2
        self.cSenseInputs = cSenseInputsFromGrid + cSenseInputsMisc + cSenseInputsFromPollenators

        self.cMotorOutputs = MotorNeurons.allCases.count

        let div = Int.random(in: NetStructure.cLayersRange)
        var cNeuronsHiddenLayer = cSenseInputs / div

        var hiddenLayersStructure = [Int]()
        while cNeuronsHiddenLayer > (div * cMotorOutputs) {
            hiddenLayersStructure.append(cNeuronsHiddenLayer)
            cNeuronsHiddenLayer /= div
        }

        if hiddenLayersStructure.isEmpty {
            let cFudgeNeurons = max((cSenseInputs + cMotorOutputs) / 2, 1)
            hiddenLayersStructure = [cFudgeNeurons]
        }

        // This ugliness is just so I can compare the layer structure
        // to the parent layer structure; I'm feeling too lazy to think
        // about how to make it into an if/let construct
        let dd: [Int]? = [cSenseInputs] + hiddenLayersStructure + [cMotorOutputs]
        let layerStructureIsClone = (dd == parentLayerDescriptors)

        self.layerDescriptors = dd!

        (self.cNeurons, self.cBiases, self.cWeights) =
            NetStructure.computeNetParameters(layerDescriptors)

        let cp = (layerStructureIsClone && (self.cSenseRings == (cSenseRings ?? 0)))

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
