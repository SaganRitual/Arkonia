enum MiscSenses: Int, CaseIterable {
    case x, y, hunger, asphyxiation
    case gestationFullness, dayFullness, yearFullness
}

enum MotorNeurons: Int, CaseIterable {
    case jumpTarget, jumpSpeed
}

struct NetStructure {
    init(
        layerDescriptors: ArraySlice<Int>,
        hiddenLayerStructure: [Int],
        cMotorOutputs: Int,
        cSenseInputs: Int,
        cNeurons: Int,
        cCellsWithinSenseRange: Int,
        cSenseRings: Int,
        cSenseInputsFromGrid: Int,
        cSenseInputsMisc: Int,
        cSenseInputsFromPollenators: Int,
        isCloneOfParent: Bool,
        cBiases: Int,
        cWeights: Int
    ) {
        self.layerDescriptors = layerDescriptors
        self.hiddenLayerStructure = hiddenLayerStructure
        self.cMotorOutputs = cMotorOutputs
        self.cSenseInputs = cSenseInputs
        self.cNeurons = cNeurons
        self.cCellsWithinSenseRange = cCellsWithinSenseRange
        self.cSenseRings = cSenseRings
        self.cSenseInputsFromGrid = cSenseInputsFromGrid
        self.cSenseInputsMisc = cSenseInputsMisc
        self.cSenseInputsFromPollenators = cSenseInputsFromPollenators
        self.isCloneOfParent = isCloneOfParent

        self.cNetParameters = cBiases + cWeights
    }

    init(
        layerDescriptors: ArraySlice<Int>,
        hiddenLayerStructure: [Int],
        cMotorOutputs: Int,
        cSenseInputs: Int,
        cNeurons: Int,
        cCellsWithinSenseRange: Int,
        cSenseRings: Int,
        cSenseInputsFromGrid: Int,
        cSenseInputsMisc: Int,
        cSenseInputsFromPollenators: Int,
        isCloneOfParent: Bool,
        cNetParameters: Int
    ) {
        self.layerDescriptors = layerDescriptors
        self.hiddenLayerStructure = hiddenLayerStructure
        self.cMotorOutputs = cMotorOutputs
        self.cSenseInputs = cSenseInputs
        self.cNeurons = cNeurons
        self.cCellsWithinSenseRange = cCellsWithinSenseRange
        self.cSenseRings = cSenseRings
        self.cSenseInputsFromGrid = cSenseInputsFromGrid
        self.cSenseInputsMisc = cSenseInputsMisc
        self.cSenseInputsFromPollenators = cSenseInputsFromPollenators
        self.isCloneOfParent = isCloneOfParent
        self.cNetParameters = cNetParameters
    }

    static let cLayersRange: ClosedRange<Int> = 2...5
    static let cSenseRingsRange: ClosedRange<Int> = 1...8

    let layerDescriptors: ArraySlice<Int>

    let hiddenLayerStructure: [Int]
    let cMotorOutputs: Int
    let cSenseInputs: Int
    let cNeurons: Int
    let cNetParameters: Int

    let cCellsWithinSenseRange: Int
    let cSenseRings: Int

    let cSenseInputsFromGrid: Int
    let cSenseInputsMisc: Int
    let cSenseInputsFromPollenators: Int

    let isCloneOfParent: Bool

    // New net structure based on parent if there is one, from scratch otherwise
    static func makeNetStructure(_ parentNetStructure: NetStructure?) -> NetStructure {
        if let p = parentNetStructure { return Mutator.mutateNetStructure(p) }

        let cSenseRings = Int.random(in: NetStructure.cSenseRingsRange)
        return makeNetStructure(cSenseRings: cSenseRings)
    }

    // New net structure based partly on parent, with mutated cSenseRings
    static func makeNetStructure(
        _ parentNetStructure: NetStructure, _ cSenseRings: Int
    ) -> NetStructure {
        // From parent, unchanged
        let cSenseInputsMisc = parentNetStructure.cSenseInputsMisc
        let cSenseInputsFromPollenators = parentNetStructure.cSenseInputsFromPollenators
        let cMotorOutputs = MotorNeurons.allCases.count
        let hiddenLayerStructure = parentNetStructure.hiddenLayerStructure

        // Values dependent on cSenseRings
        let cCellsPerSide = 1 + 2 * cSenseRings
        let cCellsWithinSenseRange = cCellsPerSide * cCellsPerSide
        let cSenseInputsFromGrid = cCellsWithinSenseRange * 2

        let cSenseInputs = cSenseInputsFromGrid + cSenseInputsMisc + cSenseInputsFromPollenators

        let layerDescriptors: ArraySlice<Int> =
            [cSenseInputs] + hiddenLayerStructure + [cMotorOutputs]

        let cNeurons = layerDescriptors.reduce(0, +)

        let (cBiases, cWeights) = computeNetParameters(layerDescriptors)

        let isCloneOfParent = (cSenseRings == parentNetStructure.cSenseRings)

        let newNet = NetStructure(
            layerDescriptors: layerDescriptors,
            hiddenLayerStructure: hiddenLayerStructure, cMotorOutputs: cMotorOutputs,
            cSenseInputs: cSenseInputs, cNeurons: cNeurons, cCellsWithinSenseRange: cCellsWithinSenseRange,
            cSenseRings: cSenseRings, cSenseInputsFromGrid: cSenseInputsFromGrid,
            cSenseInputsMisc: cSenseInputsMisc,
            cSenseInputsFromPollenators: cSenseInputsFromPollenators,
            isCloneOfParent: isCloneOfParent, cBiases: cBiases, cWeights: cWeights
        )

        return newNet
    }

    // New net structure based mostly on parent, with mutated hidden layer structure
    static func makeNetStructure(
        _ parentNetStructure: NetStructure, _ hiddenLayerStructure: [Int]
    ) -> NetStructure {
        hardAssert(!hiddenLayerStructure.isEmpty, "hardAssert \(#file):\(#line)")

        // From parent, unchanged
        let cSenseRings = parentNetStructure.cSenseRings
        let cSenseInputsFromGrid = parentNetStructure.cSenseInputsFromGrid
        let cSenseInputsMisc = parentNetStructure.cSenseInputsMisc
        let cSenseInputsFromPollenators = parentNetStructure.cSenseInputsFromPollenators
        let cMotorOutputs = MotorNeurons.allCases.count

        let cCellsWithinSenseRange = parentNetStructure.cCellsWithinSenseRange
        let cSenseInputs = parentNetStructure.cSenseInputs

        let layerDescriptors: ArraySlice<Int> =
            [cSenseInputs] + hiddenLayerStructure + [cMotorOutputs]

        let cNeurons = layerDescriptors.reduce(0, +)
        let cNetParameters = parentNetStructure.cNetParameters

        let isCloneOfParent = hiddenLayerStructure == parentNetStructure.hiddenLayerStructure

        let newNet = NetStructure(
            layerDescriptors: layerDescriptors,
            hiddenLayerStructure: hiddenLayerStructure, cMotorOutputs: cMotorOutputs,
            cSenseInputs: cSenseInputs, cNeurons: cNeurons, cCellsWithinSenseRange: cCellsWithinSenseRange,
            cSenseRings: cSenseRings, cSenseInputsFromGrid: cSenseInputsFromGrid,
            cSenseInputsMisc: cSenseInputsMisc,
            cSenseInputsFromPollenators: cSenseInputsFromPollenators,
            isCloneOfParent: isCloneOfParent, cNetParameters: cNetParameters
        )

        return newNet
    }

    // New net structure based on number of sense rings
    static func makeNetStructure(cSenseRings: Int) -> NetStructure {
        let cCellsPerSide = 1 + 2 * cSenseRings
        let cCellsWithinSenseRange = cCellsPerSide * cCellsPerSide

        let cSenseInputsFromGrid = cCellsWithinSenseRange * 2
        let cSenseInputsMisc = MiscSenses.allCases.count
        let cSenseInputsFromPollenators = Arkonia.cPollenators * 2
        let cSenseInputs = cSenseInputsFromGrid + cSenseInputsMisc + cSenseInputsFromPollenators

        let cMotorOutputs = MotorNeurons.allCases.count

//        let div = Int.random(in: NetStructure.cLayersRange)
//        var cNeuronsHiddenLayer = cSenseInputs / div

//        var hiddenLayerStructure = [Int]()

//        while cNeuronsHiddenLayer > (div * cMotorOutputs) {
//            hiddenLayerStructure.append(cNeuronsHiddenLayer)
//            cNeuronsHiddenLayer /= div
//        }
//
//        if hiddenLayerStructure.isEmpty {
//            let cFudgeNeurons = max((cSenseInputs + cMotorOutputs) / 2, 1)
//            hiddenLayerStructure = [cFudgeNeurons]
//        }

        let layerDescriptors: ArraySlice<Int> = [2, 2, 2]
//            [cSenseInputs] + hiddenLayerStructure + [cMotorOutputs]

        let cNeurons = layerDescriptors.reduce(0, +)

        let (cBiases, cWeights) = computeNetParameters(layerDescriptors)

        return NetStructure(
            layerDescriptors: layerDescriptors,
            hiddenLayerStructure: [2], cMotorOutputs: cMotorOutputs,
            cSenseInputs: cSenseInputs, cNeurons: cNeurons, cCellsWithinSenseRange: cCellsWithinSenseRange,
            cSenseRings: cSenseRings, cSenseInputsFromGrid: cSenseInputsFromGrid,
            cSenseInputsMisc: cSenseInputsMisc,
            cSenseInputsFromPollenators: cSenseInputsFromPollenators,
            isCloneOfParent: false, cBiases: cBiases, cWeights: cWeights
        )
    }

    static func computeNetParameters(_ layers: ArraySlice<Int>) -> (Int, Int) {
        let cWeights = zip(layers.dropLast(), layers.dropFirst()).reduce(0) { $0 + ($1.0 * $1.1) }
        let cBiases = layers.dropFirst().reduce(0, +)
        return (cBiases, cWeights)
    }

    func getSegmentLength(whichSegment: Int, dimensions: Int) -> Int {
        let elementCounts = (dimensions == 1) ?
            layerDescriptors.map { $0 } :
            zip(layerDescriptors.dropLast(), layerDescriptors.dropFirst()).map { $0 * $1 }

        return elementCounts[whichSegment]
    }
}
