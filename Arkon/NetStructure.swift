enum MiscSenses: Int, CaseIterable {
    case x, y, hunger, asphyxiation
    case gestationFullness, dayFullness, yearFullness
}

enum MotorNeurons: Int, CaseIterable {
    case jumpTarget, jumpSpeed
}

struct NetStructure {
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

    static let layerStructures: [Int: [[Int]]] = [
        1: [
            [35, 32, 16, 8, 4, 2], //  1: (2 *  3^2) + 7 + 10
            [35, 17, 8, 4, 2],
            [35, 11, 2],
            [35, 8, 2]
        ],
        2: [
            [67, 64, 32, 16, 8, 4, 2], //  2: (2 *  5^2) + 7 + 10
            [67, 33, 16, 8, 4, 2],
            [67, 22, 7, 2],
            [67, 16, 4, 2]
        ],
        3: [
            [115, 64, 32, 16, 8, 4, 2], //  3: (2 *  7^2) + 7 + 10
            [115, 57, 28, 14, 7, 2],
            [115, 38, 12, 2],
            [115, 28, 7, 2]
        ],
        4: [
            [179, 128, 64, 32, 16, 8, 4, 2], //  4: (2 *  9^2) + 7 + 10
            [179, 88, 44, 22, 11, 5, 2],
            [179, 59, 19, 6, 2],
            [179, 44, 11, 2]
        ],
        5: [
            [259, 256, 128, 64, 32, 16, 8, 4, 2], //  5: (2 * 11^2) + 7 + 10
            [259, 130, 65, 32, 16, 8, 4, 2],
            [259, 86, 25, 8, 2],
            [259, 65, 16, 4, 2]
        ],
        6: [
            [355, 256, 128, 64, 32, 16, 8, 4, 2], //  6: (2 * 13^2) + 7 + 10
            [355, 177, 88, 44, 22, 11, 5, 2],
            [355, 118, 39, 13, 2],
            [355, 88, 22, 5, 2]
            ],
        7: [
            [467, 256, 128, 64, 32, 16, 8, 4, 2], //  7: (2 * 15^2) + 7 + 10
            [467, 233, 116, 58, 29, 14, 7, 2],
            [467, 155, 51, 17, 5, 2],
            [467, 116, 29, 7, 2]
        ],
        8: [
            [595, 512, 256, 128, 64, 32, 16, 8, 4, 2], //  8: (2 * 17^2) + 7 + 10
            [595, 297, 148, 74, 37, 18, 9, 4, 2],
            [595, 198, 66, 22, 7, 2],
            [595, 148, 37, 9, 2]
        ],
        9: [
            [739, 512, 256, 128, 64, 32, 16, 8, 4, 2], //  9: (2 * 19^2) + 7 + 10
            [739, 369, 184, 92, 46, 23, 11, 5, 2],
            [739, 246, 82, 27, 9, 2],
            [739, 184, 46, 11, 2]
        ],
        10: [
            [899, 512, 256, 128, 64, 32, 16, 8, 4, 2],  // 10: (2 * 21^2) + 7 + 10
            [899, 449, 224, 112, 56, 28, 14, 7, 2],
            [899, 299, 99, 33, 11, 2],
            [899, 224, 56, 14 , 2]
        ]
    ]

    init(_ cSenseRings: Int?, _ parentLayerDescriptors: [Int]?) {
        self.cSenseRings = cSenseRings ?? Int.random(in: NetStructure.cSenseRingsRange)
        self.layerDescriptors = NetStructure.layerStructures[self.cSenseRings]!.randomElement()!

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

        hardAssert(debugCNeurons == cNeurons) { "\(#line) in \(#file)" }

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
