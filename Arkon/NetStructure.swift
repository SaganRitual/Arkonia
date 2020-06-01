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

    let cHiddenNeurons: Int
    let cMotorNeurons: Int
    let cSenseNeurons: Int

    let cBiases: Int
    let cNeurons: Int
    let cWeights: Int

    let cCellsWithinSenseRange: Int
    let cSenseRings: Int

    let cSenseNeuronsGrid: Int
    let cSenseNeuronsPollenators: Int
    let cSenseNeuronsMisc: Int

    var isCloneOfParent = false

    let layerStructures: [[Int]] = [
                            [35, 32, 16, 8, 4, 2], //  1: (2 *  3^2) + 7 + 10
                        [67, 64, 32, 16, 8, 4, 2], //  2: (2 *  5^2) + 7 + 10
                       [115, 64, 32, 16, 8, 4, 2], //  3: (2 *  7^2) + 7 + 10
                  [179, 128, 64, 32, 16, 8, 4, 2], //  4: (2 *  9^2) + 7 + 10
             [259, 256, 128, 64, 32, 16, 8, 4, 2], //  5: (2 * 11^2) + 7 + 10
             [355, 256, 128, 64, 32, 16, 8, 4, 2], //  6: (2 * 13^2) + 7 + 10
             [467, 256, 128, 64, 32, 16, 8, 4, 2], //  7: (2 * 15^2) + 7 + 10
        [595, 512, 256, 128, 64, 32, 16, 8, 4, 2], //  8: (2 * 17^2) + 7 + 10
        [739, 512, 256, 128, 64, 32, 16, 8, 4, 2], //  9: (2 * 19^2) + 7 + 10
        [899, 512, 256, 128, 64, 32, 16, 8, 4, 2]  // 10: (2 * 21^2) + 7 + 10
    ]

    init(_ cSenseRings: Int?, _ parentLayerDescriptors: [Int]?) {
        self.cSenseRings = cSenseRings ?? Int.random(in: NetStructure.cSenseRingsRange)

        let structureIndex = self.cSenseRings - 1
        self.layerDescriptors = layerStructures[structureIndex]

        self.cCellsWithinSenseRange = {
            let cCellsPerSide = 1 + 2 * (cSenseRings ?? 1)
            return cCellsPerSide * cCellsPerSide
        }()

        self.cSenseNeurons = self.layerDescriptors[0]

        self.cSenseNeuronsMisc = MiscSenses.allCases.count
        self.cSenseNeuronsPollenators = Arkonia.cPollenators * 2
        self.cSenseNeuronsGrid = self.cSenseNeurons - (self.cSenseNeuronsMisc + self.cSenseNeuronsPollenators)

        self.cMotorNeurons = MotorNeurons.allCases.count

        self.cHiddenNeurons = self.layerDescriptors.dropFirst().dropLast().reduce(0, +)

        let debugCNeurons = cSenseNeurons + cHiddenNeurons + cMotorNeurons

        // This ugliness is just so I can compare the layer structure
        // to the parent layer structure; I'm feeling too lazy to think
        // about how to make it into an if/let construct
        let layerStructureIsClone = (self.layerDescriptors == parentLayerDescriptors)

        (self.cNeurons, self.cBiases, self.cWeights) =
            NetStructure.computeNetParameters(layerDescriptors)

        hardAssert(debugCNeurons == cNeurons, "\(#line) in \(#file)")

        let cp = layerStructureIsClone && (self.cSenseRings == cSenseRings)

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
