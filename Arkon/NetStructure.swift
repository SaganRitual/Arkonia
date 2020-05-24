enum MiscSenses: Int, CaseIterable {
    case x, y, hunger, asphyxiation
    case gestationFullness, dayFullness, yearFullness
}

enum MotorNeurons: Int, CaseIterable {
    case jumpTarget, jumpSpeed
}

struct NetStructure {
    static let cLayersRange: ClosedRange<Int> = 2...5
    static let cSenseRingsRange: ClosedRange<Int> = 1...8

    let layerDescriptors: ArraySlice<Int>

    let hiddenLayerStructure: [Int]
    let cMotorOutputs: Int
    let cSenseInputs: Int
    let cNeurons: Int

    let cCellsWithinSenseRange: Int
    let cSenseRings: Int

    let cSenseInputsFromGrid: Int
    let cSenseInputsMisc: Int
    let cSenseInputsFromPollenators: Int

    var cBiases = 0
    var cWeights = 0

    let isCloneOfParent: Bool

    // Default to creating an unmutated copy of the original strand
    var assembleStrand: (([Float], Int) -> [Float]) = { originalStrand, _ in return Array(originalStrand) }

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

        let (cBiases, cWeights) = computeNetParameters(layerDescriptors)
        let cNeurons = layerDescriptors.reduce(0, +)

        let isCloneOfParent = (cSenseRings == parentNetStructure.cSenseRings)

        let newNet = NetStructure(
            layerDescriptors: layerDescriptors,
            hiddenLayerStructure: hiddenLayerStructure, cMotorOutputs: cMotorOutputs,
            cSenseInputs: cSenseInputs, cNeurons: cNeurons, cCellsWithinSenseRange: cCellsWithinSenseRange,
            cSenseRings: cSenseRings, cSenseInputsFromGrid: cSenseInputsFromGrid,
            cSenseInputsMisc: cSenseInputsMisc,
            cSenseInputsFromPollenators: cSenseInputsFromPollenators,
            cBiases: cBiases, cWeights: cWeights, isCloneOfParent: isCloneOfParent
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

        let isCloneOfParent = hiddenLayerStructure == parentNetStructure.hiddenLayerStructure

        let newNet = NetStructure(
            layerDescriptors: layerDescriptors,
            hiddenLayerStructure: hiddenLayerStructure, cMotorOutputs: cMotorOutputs,
            cSenseInputs: cSenseInputs, cNeurons: cNeurons, cCellsWithinSenseRange: cCellsWithinSenseRange,
            cSenseRings: cSenseRings, cSenseInputsFromGrid: cSenseInputsFromGrid,
            cSenseInputsMisc: cSenseInputsMisc,
            cSenseInputsFromPollenators: cSenseInputsFromPollenators,
            isCloneOfParent: isCloneOfParent
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

        let div = Int.random(in: NetStructure.cLayersRange)
        var cNeuronsHiddenLayer = cSenseInputs / div

        var hiddenLayerStructure = [Int]()

        while cNeuronsHiddenLayer > (div * cMotorOutputs) {
            hiddenLayerStructure.append(cNeuronsHiddenLayer)
            cNeuronsHiddenLayer /= div
        }

        let layerDescriptors: ArraySlice<Int> =
            [cSenseInputs] + hiddenLayerStructure + [cMotorOutputs]

        let (cBiases, cWeights) = computeNetParameters(layerDescriptors)
        let cNeurons = layerDescriptors.reduce(0, +)

        return NetStructure(
            layerDescriptors: layerDescriptors,
            hiddenLayerStructure: hiddenLayerStructure, cMotorOutputs: cMotorOutputs,
            cSenseInputs: cSenseInputs, cNeurons: cNeurons, cCellsWithinSenseRange: cCellsWithinSenseRange,
            cSenseRings: cSenseRings, cSenseInputsFromGrid: cSenseInputsFromGrid,
            cSenseInputsMisc: cSenseInputsMisc,
            cSenseInputsFromPollenators: cSenseInputsFromPollenators,
            cBiases: cBiases, cWeights: cWeights, isCloneOfParent: false
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
