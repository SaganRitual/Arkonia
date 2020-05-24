extension NetStructure {
    func assembleStrand_dropLayer(
        _ removeAtOffsetInHiddenLayers: Int
    ) -> (([Float], Int) -> [Float]) {
        return { inputStrand, dimensions in
            let cPrefixElements = (0..<removeAtOffsetInHiddenLayers).map {
                self.getSegmentLength(
                    whichSegment: $0, dimensions: dimensions
                )
            }.reduce(0, +)

            let cDropElements = self.getSegmentLength(
                whichSegment: removeAtOffsetInHiddenLayers, dimensions: dimensions
            )

            let suffixSS = cPrefixElements + cDropElements
            let cSuffixElements = inputStrand.count - suffixSS

            let suffix = (cSuffixElements == 0) ? [] : inputStrand.suffix(from: suffixSS)
            return Array(inputStrand.prefix(upTo: cPrefixElements) + suffix)
        }
    }

    func assembleStrand_duplicateLayer(
        _ duplicateAt: Int, _ insertAt: Int
    ) -> (([Float], Int) -> [Float]) {
        return { inputStrand, dimensions in
            let cPrefixElements = (0..<insertAt).map {
                self.getSegmentLength(
                    whichSegment: $0, dimensions: dimensions
                )
            }.reduce(0, +)

            let suffixSS = insertAt + 1
            let cSuffixElements = inputStrand.count - suffixSS

            let cDuplicatedElements = self.getSegmentLength(
                whichSegment: duplicateAt, dimensions: dimensions
            )

            let pre = cPrefixElements
            let dup = cDuplicatedElements
            let sufSeg = (cSuffixElements == 0) ? [] : inputStrand.suffix(from: suffixSS)

            let newRawStrand =
                inputStrand.prefix(upTo: pre)
                + inputStrand[pre..<dup]
                + sufSeg

            return Array(newRawStrand)
        }
    }

    func assembleStrand_duplicateAndMutateLayer(
        _ duplicateAt: Int, _ insertAt: Int
    ) -> (([Float], Int) -> [Float]) {
        return { inputStrand, dimensions in
            let cPrefixElements = (0..<insertAt).map {
                self.getSegmentLength(
                    whichSegment: $0, dimensions: dimensions
                )
            }.reduce(0, +)

            let suffixSS = insertAt + 1
            let cSuffixElements = inputStrand.count - suffixSS

            let cDuplicatedElements = self.getSegmentLength(
                whichSegment: duplicateAt, dimensions: dimensions
            )

            let pre = cPrefixElements
            let dup = cDuplicatedElements
            let duplicatedSegment = inputStrand[pre..<dup]

            let mutatedSegment = Mutator.mutateNetStrand(
                parentStrand: duplicatedSegment, targetLength: pre
            )

            let suffixSegment = (cSuffixElements == 0) ? [] : inputStrand.suffix(from: suffixSS)

            let newRawStrand =
                inputStrand.prefix(upTo: pre)
                + mutatedSegment
                + suffixSegment

            return Array(newRawStrand)
        }
    }

    func assembleStrand_insertRandomLayer(
        _ insertAt: Int
    ) -> (([Float], Int) -> [Float]) {
        return { inputStrand, dimensions in
            let cPrefixElements = (0..<insertAt).map {
                self.getSegmentLength(
                    whichSegment: $0, dimensions: dimensions
                )
            }.reduce(0, +)

            let newSegmentCElements = self.getSegmentLength(
                whichSegment: insertAt, dimensions: dimensions
            )

            let (lo, hi): (Float, Float) = (-1, 1)
            let newSegment: [Float] = (0..<newSegmentCElements).map {
                _ in Float.random(in: lo..<hi)
            }

            let newRawStrand =
                inputStrand.prefix(upTo: cPrefixElements)
                + newSegment[...]
                + inputStrand.suffix(from: cPrefixElements)

            return Array(newRawStrand)
        }
    }
}
