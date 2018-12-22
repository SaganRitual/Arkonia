//
// Permission is hereby granted, free of charge, to any person obtaining a
// copy of this software and associated documentation files (the "Software"),
// to deal in the Software without restriction, including without limitation
// the rights to use, copy, modify, merge, publish, distribute, sublicense,
// and/or sell copies of the Software, and to permit persons to whom the
// Software is furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
// FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS
// IN THE SOFTWARE.
//

import Foundation

private enum DecodeState {
    case diagnostics, endOfStrand, inLayer, inNeuron, noLayer
}

class Decoder {
    static var d: Decoder!

    enum BirthDefect: Error {
        case emptyLayer
    }

    var inputGenome: GenomeSlice!

    enum InputMode { case head, meat, tail }
    var inputMode = InputMode.head
    var aTrue = 0
    var aFalse = 0

    fileprivate var decodeState: DecodeState = .noLayer
    var workspace = String()

    init() {
        precondition(Decoder.d == nil)
        Decoder.d = self

        workspace.reserveCapacity(1024 * 1024)
    }

    func decode() -> Bool {
        self.reset()
        Translators.t.reset()
        Translators.t.newBrain()

        var hmCommandeeredNeurons = 0
        let reversed = self.inputGenome.reversed()

        guard let rLayerInsertionPoint = reversed.firstIndex(where: {
            let c = GSGoalSuite.selectionControls.howManyMotorNeurons
            let found = hmCommandeeredNeurons >= c

            if $0 == Manipulator.neu {
                hmCommandeeredNeurons += 1
            }

            return found
        }) else { /*print("Test subject did not survive birth; genome:", self.inputGenome);*/ return false }

        let distance = reversed.distance(from: rLayerInsertionPoint, to: reversed.endIndex)
        let fLayerInsertionPoint = inputGenome.index(inputGenome.startIndex, offsetBy: distance)

        workspace += inputGenome[..<fLayerInsertionPoint] + Manipulator.layb[...] +
                inputGenome[fLayerInsertionPoint...].replacingOccurrences(of: Manipulator.layb, with: "")

        decodeLayers(workspace[...])
        Translators.t.endOfStrand()

//        Translators.t.getBrain().show(tabs: "", override: true)
//        print(inputGenome)
        return true
    }

    func newBrain() { Translators.t.newBrain() }

    func reset() {
        self.decodeState = .noLayer
        self.inputMode = .head
        self.workspace.removeAll(keepingCapacity: true)
    }
}

private extension Decoder {
    func decodeLayers(_ slice: GenomeSlice) {
        var start = slice.startIndex
        let end = slice.endIndex

        while start != end {
            start = decodeOneGene(slice[start...])
        }
    }

    func decodeOneGene(_ slice_: GenomeSlice) -> GenomeSlice.Index {
        var slice = slice_[...]

        // Just ignore any unrecognized characters, in case I screw up the data
        let nextValidTokenIndex = slice.startIndex
        let goodDataIndex = discardAnyGarbage(slice)
        if goodDataIndex == slice.endIndex { decodeState = .endOfStrand }
        if goodDataIndex != nextValidTokenIndex { slice = slice[goodDataIndex...] }

        var symbolsConsumed = 0
        switch decodeState {
            // Skip the diagnostics, or the decoder will create
        // a nice new layer for us, with a single neuron
        case .diagnostics: symbolsConsumed = dispatch_noLayer(slice)
        case .noLayer: symbolsConsumed = dispatch_noLayer(slice)
        case .inLayer: symbolsConsumed = dispatch_inLayer(slice)
        case .inNeuron: symbolsConsumed = dispatch_inNeuron(slice)
        case .endOfStrand: break
        }

        slice = slice.dropFirst(symbolsConsumed)
        return slice.startIndex
    }

    func skipBadTokens(_ slice: GenomeSlice) -> GenomeSlice.Index {
        let r = Manipulator.recognizedTokens
        if let r = slice.firstIndex(where: { r.contains($0) }) {
            return r
        }

        self.decodeState = .endOfStrand
        return slice.startIndex
    }

    func discardAnyGarbage(_ slice: GenomeSlice) -> GenomeSlice.Index {
        guard let s = slice.first else { return slice.endIndex }

        let r = Manipulator.recognizedTokens
        if r.contains(s) { return slice.startIndex }
        else { return skipBadTokens(slice) }
    }
}

extension Decoder {
    func dispatchValueGene(_ slice: GenomeSlice) -> Int {
        var symbolsConsumed = 0
        var tSlice = slice
        let token = tSlice.first!

        symbolsConsumed += 2; tSlice = tSlice.dropFirst(2)

        let ixOfCloseParen = tSlice.firstIndex(of: ")")!
        let meatSlice = tSlice[..<ixOfCloseParen]

        switch token {
        case Manipulator.act:
            let result: Bool = parse(meatSlice)
            if result { aTrue += 1 } else { aFalse += 1 }
            Translators.t.addActivator(result)

        case Manipulator.bis: Translators.t.accumulateBias(parse(meatSlice))
        case Manipulator.fun: Translators.t.setOutputFunction(parse(meatSlice))
        case Manipulator.wgt: Translators.t.addWeight(parse(meatSlice))
        default: print("Decoder says '\(token)' is an unknown token: "); return 2
        }

        symbolsConsumed += 2 + tSlice.distance(from: tSlice.startIndex, to: ixOfCloseParen)
        return symbolsConsumed
    }
}

extension Decoder {

    func dispatch_noLayer(_ slice: GenomeSlice) -> Int {
        guard let first = slice.first else { fatalError("Thought we had a slice, but it's gone now?") }
        switch first {
        case Manipulator.lay:
            decodeState = .inLayer
            Translators.t.newLayer()
            return 2

        case Manipulator.neu:
            decodeState = .inNeuron
            Translators.t.newLayer()
            Translators.t.newNeuron()
            return 2

        case Manipulator.ifm:
            decodeState = .noLayer
            Translators.t.closeLayer()
            return 2

        default:
            decodeState = .inNeuron
            Translators.t.newLayer()
            Translators.t.newNeuron()

            return dispatchValueGene(slice)
        }
    }

    func dispatch_inLayer(_ slice: GenomeSlice) -> Int {
        guard let first = slice.first else { fatalError("Thought we had a slice, but it's gone now?") }
        switch first {
        case Manipulator.lay:
            // Got another layer marker, but it would
            // cause this one to be empty. Just ignore it.
            decodeState = .inLayer
            return 2

        case Manipulator.neu:
            decodeState = .inNeuron
            Translators.t.newNeuron()
            return 2

        case Manipulator.ifm:
            decodeState = .noLayer
            Translators.t.closeLayer()
            return 2

        default:
            decodeState = .inNeuron
            Translators.t.newNeuron()
            return dispatchValueGene(slice)
        }
    }

    func dispatch_inNeuron(_ slice: GenomeSlice) -> Int {
        guard let first = slice.first else { fatalError("Thought we had a slice, but it's gone now?") }
        switch first {
        case Manipulator.lay:
            decodeState = .inLayer
            Translators.t.closeNeuron()
            Translators.t.closeLayer()
            Translators.t.newLayer()
            return 2

        case Manipulator.neu:
            decodeState = .inNeuron
            Translators.t.closeNeuron()
            Translators.t.newNeuron()
            return 2

        case Manipulator.ifm:
            decodeState = .noLayer
            Translators.t.closeLayer()
            return 2

        default:
            return dispatchValueGene(slice)
        }
    }
}

extension Decoder {
    func setInput(to inputGenome: GenomeSlice) -> Decoder {
        self.inputGenome = inputGenome
        return self
    }

    func parse<PrimitiveType>(_ slice: GenomeSlice? = nil) -> PrimitiveType {
        fatalError("Should never come here")
    }

    func parse(_ slice: GenomeSlice? = nil) -> Bool {
        let truthy = "true", falsy = "false", stringy = String(slice!)
        switch stringy {
        case truthy: return true
        case falsy:  return false
        default: fatalError("Bad data! You said it would never be bad.")
        }
    }

    func parse(_ slice: GenomeSlice? = nil) -> Double {
        return Double(slice!)!.dTruncate()
    }

    func parse(_ slice: GenomeSlice? = nil) -> ValueDoublet {
        let values = Manipulator.splitGene(slice!)
        let baseline = Double(values[0])!.dTruncate()
        let value = Double(values[1])!.dTruncate()

        return ValueDoublet(baseline, value)
    }

    func parse(_ slice: GenomeSlice? = nil) -> Int { return Int(slice!)! }
    func parse(_ slice: GenomeSlice?) -> String { return String(slice!) }
}
