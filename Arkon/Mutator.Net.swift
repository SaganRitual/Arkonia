extension Mutator {
    static func mutateNetStrand(parentStrand p: [Float]?, targetLength: Int, value: Float? = nil) -> [Float] {
        if let parentStrand = p {
            return mutateNetStrand(parentStrand: parentStrand[...], targetLength: targetLength)
        }

        // Setup a range that allows us to get -1..<1 random values or all
        // zeros in the new array
        let (lo, hi): (Int, Int) = (value == nil) ? (-1, 1) : ((value! == 0) ? (0, 0) : (-1, 1))
        let fromScratch: [Float] = (0..<targetLength).map { _ in Float(Int.random(in: lo...hi)) }

        Debug.log(level: 93) { "Generate from scratch = \(fromScratch)" }
        return fromScratch
    }

    static func mutateNetStrand(parentStrand: ArraySlice<Float>, targetLength: Int, value: Float? = nil) -> [Float] {
        let ms = Mutator.mutateRandomDoubles(parentStrand)
        if let mutatedStrand = ms {

            let c = mutatedStrand.count

            if c > targetLength {
                return Array(mutatedStrand.prefix(targetLength))
            } else if c < targetLength {
                let n = Float(-1), p = Float(1)
                return mutatedStrand + (c..<targetLength).map { _ in Float.random(in: n..<p) }
            }

            return mutatedStrand
        }

        return Array(parentStrand)  // Not mutated, but child needs its own array
    }

    static func mutateNetStructure(_ parentNetStructure: NetStructure) -> NetStructure {
        // 70% chance that the structure won't change at all
        if Int.random(in: 0..<100) < 70 {
            Debug.log(level: 121) { "no mutation to net structure" }

            return parentNetStructure
        }

        Debug.log(level: 121) { "mutating net structure" }

        switch NetMutation.allCases.randomElement()! {
        case .dropLayer:               return dropLayer(parentNetStructure)
        case .duplicateLayer:          return duplicateLayer(parentNetStructure)
        case .duplicateAndMutateLayer: return duplicateAndMutateLayer(parentNetStructure)
        case .insertRandomLayer:       return insertRandomLayer(parentNetStructure)
        case .mutateCRings:            return mutateCRings(parentNetStructure)
        }
    }
}

private extension Mutator {
    static func dropLayer(_ parentNetStructure: NetStructure) -> NetStructure {
        var hiddenLayerStructure = parentNetStructure.hiddenLayerStructure
        var removeAt: Int?

        if hiddenLayerStructure.count > 1 {
            removeAt = Int.random(in: 0..<hiddenLayerStructure.count)
            hiddenLayerStructure.remove(at: removeAt!)
        }

        var ns = NetStructure.makeNetStructure(
            parentNetStructure, hiddenLayerStructure
        )

        // The call for mutation comes later; here, we're only setting up the
        // function to assemble the strand when that happens
        if let r = removeAt { ns.assembleStrand = ns.assembleStrand_dropLayer(r) }

        return ns
    }

    static func duplicateLayer(_ parentNetStructure: NetStructure) -> NetStructure {
        let insertAt = Int.random(in: 0..<parentNetStructure.hiddenLayerStructure.count)
        let duplicateAt = Int.random(in: 0..<parentNetStructure.hiddenLayerStructure.count)
        let duplicated = parentNetStructure.hiddenLayerStructure[duplicateAt]

        var newHiddenLayerStructure = parentNetStructure.hiddenLayerStructure
        newHiddenLayerStructure.insert(duplicated, at: insertAt)

        var ns = NetStructure.makeNetStructure(
            parentNetStructure, newHiddenLayerStructure
        )

        ns.assembleStrand = ns.assembleStrand_duplicateLayer(duplicateAt, insertAt)

        return ns
    }

    static func duplicateAndMutateLayer(_ parentNetStructure: NetStructure) -> NetStructure {
        let insertAt = Int.random(in: 0..<parentNetStructure.hiddenLayerStructure.count)
        let duplicateAt = Int.random(in: 0..<parentNetStructure.hiddenLayerStructure.count)
        let duplicatedValue = parentNetStructure.hiddenLayerStructure[duplicateAt]

        let (mutatedValue, _) = Mutator.mutate(from: duplicatedValue)

        var newHiddenLayerStructure = parentNetStructure.hiddenLayerStructure
        newHiddenLayerStructure.insert(mutatedValue, at: insertAt)

        var ns = NetStructure.makeNetStructure(
            parentNetStructure, newHiddenLayerStructure
        )

        ns.assembleStrand = ns.assembleStrand_duplicateAndMutateLayer(duplicateAt, insertAt)

        return ns
    }

    static func insertRandomLayer(_ parentNetStructure: NetStructure) -> NetStructure {
        let insertAt = Int.random(in: 0..<parentNetStructure.hiddenLayerStructure.count)

        // Minimum so we can do integer division and not end up with a zero
        let minimumCNeurons = parentNetStructure.hiddenLayerStructure.count
        let maximumCNeurons = parentNetStructure.hiddenLayerStructure.reduce(0, +)
        let cNeuronsInNewLayer = Int.random(in: 0..<maximumCNeurons) / minimumCNeurons

        var newHiddenLayerStructure = parentNetStructure.hiddenLayerStructure
        newHiddenLayerStructure.insert(cNeuronsInNewLayer, at: insertAt)

        var ns = NetStructure.makeNetStructure(
            parentNetStructure, newHiddenLayerStructure
        )

        ns.assembleStrand = ns.assembleStrand_insertRandomLayer(insertAt)

        return ns
    }

    static func mutateCRings(_ parentNetStructure: NetStructure) -> NetStructure {
        let (newCount, _) = Mutator.mutate(from: parentNetStructure.cSenseRings)
        return NetStructure.makeNetStructure(parentNetStructure, newCount)
    }
}
