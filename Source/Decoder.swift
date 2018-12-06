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

    init() {
        precondition(Decoder.d == nil)
        Decoder.d = self
    }

    fileprivate var decodeState: DecodeState = .noLayer

    func decode() -> Bool {
        self.reset()
        Translators.t.reset()
        Translators.t.newBrain()

        var hmCommandeeredNeurons = 0
        let reversed = self.inputGenome.reversed()
        guard var rLayerInsertionPoint = reversed.firstIndex(where: {
            if $0 == neu { hmCommandeeredNeurons += 1 }

            return hmCommandeeredNeurons >= selectionControls.howManyMotorNeurons
        }) else { /*print("Test subject did not survive birth");*/ return false }

        // Reversed, searched to find the nth neuron
        // Remember: reversing A(true)L_N_F(linear)_ does not result in F(linear)_N_L_A(true).
        //      it results in _)raenil(F_N_L)eurt(A. Which is ok, because it flips back to
        //      normal, but it means it's confusing and think about it a lot before changing it. Or not.
        //
        // We're scanning for N, which will look like _N.
        //
        rLayerInsertionPoint = reversed.index(after: rLayerInsertionPoint)

        let distance = reversed.distance(from: rLayerInsertionPoint, to: reversed.endIndex)

        let fLayerInsertionPoint = inputGenome.index(inputGenome.startIndex, offsetBy: distance)

        // To get it back to normal, reverse the segments and put them
        // back in reverse order: 1234567890 reversed -> 0987654321, split
        // into 0987 and 654321, reassembled as 1234567 and 7890, with the
        // marker in between them, of course.
        let commandeeredGenome = inputGenome[fLayerInsertionPoint...] + layb[...] +
                inputGenome[..<fLayerInsertionPoint]


//        decodeLayers(Statics.s.sensesInterface)
        decodeLayers(commandeeredGenome)
//        decodeLayers(Statics.s.outputsInterface)

        Translators.t.endOfStrand()
        return true // The test subject survived birth
        
//        Translators.t.getBrain().show(tabs: "", override: true)
//        print(inputGenome)
    }

    func newBrain() { Translators.t.newBrain() }

    func reset() {
        self.decodeState = .noLayer
        self.inputMode = .head
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
        if let r = slice.firstIndex(where: { Statics.s.recognizedTokens.contains($0) }) {
            return r
        }
        
        self.decodeState = .endOfStrand
        return slice.startIndex
    }
    
    func discardAnyGarbage(_ slice: GenomeSlice) -> GenomeSlice.Index {
        guard let s = slice.first else { return slice.endIndex }
        
        if Statics.s.recognizedTokens.contains(s) { return slice.startIndex }
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
        case act: Translators.t.addActivator(parse(meatSlice))
        case bis: Translators.t.setBias(parse(meatSlice))
        case fun: Translators.t.setOutputFunction(parse(meatSlice))
        case wgt: Translators.t.addWeight(parse(meatSlice))
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
        case lay:
            decodeState = .inLayer
            Translators.t.newLayer()
            return 2

        case neu:
            decodeState = .inNeuron
            Translators.t.newLayer()
            Translators.t.newNeuron()
            return 2

        case ifm:
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
        case lay:
            // Got another layer marker, but it would
            // cause this one to be empty. Just ignore it.
            decodeState = .inLayer
            return 2

        case neu:
            decodeState = .inNeuron
            Translators.t.newNeuron()
            return 2

        case ifm:
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
        case lay:
            decodeState = .inLayer
            Translators.t.closeNeuron()
            Translators.t.closeLayer()
            Translators.t.newLayer()
            return 2

        case neu:
            decodeState = .inNeuron
            Translators.t.closeNeuron()
            Translators.t.newNeuron()
            return 2

        case ifm:
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

    func parse(_ slice: GenomeSlice? = nil) -> ValueDoublet {
        let values = Utilities.splitGene(slice!)
        let baseline = Double(values[0])!.dTruncate()
        let value = Double(values[1])!.dTruncate()

        return ValueDoublet(baseline, value)
    }

    func parse(_ slice: GenomeSlice? = nil) -> Int { return Int(slice!)! }
    func parse(_ slice: GenomeSlice?) -> String { return String(slice!) }
}
