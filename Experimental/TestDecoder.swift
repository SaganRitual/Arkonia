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

protocol ValueParserProtocol {
    func decode()
    func parseBool(_ slice: StrandSlice?) -> Bool
    func parseDouble(_ slice: StrandSlice?) -> Double
    func parseInt(_ slice: StrandSlice?) -> Int
    func setInput(to inputStrand: String) -> ValueParserProtocol
    func setDecoder(decoder: ValueParserProtocol)
    func setDefaultInput() -> ValueParserProtocol
}

class DecoderTestParsers: ValueParserProtocol {
    var decoder: ValueParserProtocol!

    func setDecoder(decoder: ValueParserProtocol) { self.decoder = decoder }
    func decode() {}

    func parseBool(_ slice: StrandSlice? = nil) -> Bool {
        return decoder.parseBool(slice)
    }

    func parseDouble(_ slice: StrandSlice? = nil) -> Double {
        return decoder.parseDouble(slice)
    }

    func parseInt(_ slice: StrandSlice? = nil) -> Int {
        
        let p = decoder.parseInt(slice)
        return p
    }
    
    func setInput(to inputStrand: String) -> ValueParserProtocol {
        return self
    }
    
    func setDefaultInput() -> ValueParserProtocol {
        return self
    }
}

class Layer {
    var neurons = [Neuron]()
    var underConstruction: Neuron!
    
    var firstPass = true
    
    func addActivator(_ value: Bool) { underConstruction.activators.append(value) }
    
    func closeNeuron() { neurons.append(underConstruction); underConstruction = nil }
    func newNeuron() { underConstruction = Neuron() }

    func addWeight(_ value: Double) { underConstruction.weights.append(value) }
    
    func endOfStrand() {
        if let u = underConstruction { neurons.append(u); underConstruction = nil }
    }
    
    func setBias(_ value: Double) { underConstruction.bias = value }
    func setThreshold(_ value: Double) { underConstruction.threshold = value }
}

class Neuron {
    var bias: Double?
    var threshold: Double?

    var activators = [Bool](), weights = [Double]()
    
    func addActivator(_ active: Bool) { activators.append(active) }
    func addWeight(_ weight: Double) { weights.append(weight) }
    func setBias(_ value: Double) { bias = value }
    func setThreshold(_ value: Double) { threshold = value }
}

protocol GeneDecoderProtocol {
    var reachedEndOfStrand: Bool { get set }

    func addActivator(_ active: Bool)
    func addWeight(_ weight: Double)

    func closeNeuron()
    func closeLayer()

    func endOfStrand()

    func newLayer()
    func newNeuron()

    func reset()
    
    func setBias(_ value: Double)
    func setThreshold(_ value: Double)
}

class DecoderTestGeneTranslators: GeneDecoderProtocol {
    var reachedEndOfStrand = false
    
    var layerStack = [Layer]()
    var underConstruction: Layer!
    
    func addActivator(_ active: Bool) { underConstruction.underConstruction.addActivator(active) }
    func addWeight(_ weight: Double) { underConstruction.underConstruction.addWeight(weight) }

    func closeLayer() { if let u = underConstruction { layerStack.append(u) }}
    func closeNeuron() { underConstruction.closeNeuron() }

    func endOfStrand() {
        if let u = underConstruction {
            layerStack.append(u)
            underConstruction = nil
            reachedEndOfStrand = true
        }
        
        if let layer = layerStack.last { layer.endOfStrand() }
    }

    func newLayer() {
        if let u = underConstruction { layerStack.append(u); underConstruction = nil }
        else { underConstruction = Layer() }
    }

    func newNeuron() { underConstruction.newNeuron() }
    
    func reset() { reachedEndOfStrand = false; layerStack.removeAll() }

    func setBias(_ value: Double) { underConstruction!.setThreshold(value) }
    func setThreshold(_ value: Double) { underConstruction!.setThreshold(value) }
}

struct TestDecoder {
    let decoder: StrandDecoder
    let parsers = DecoderTestParsers()
    let translators = DecoderTestGeneTranslators()
    
    var decoderTestInput = ""
    
    let maxLayers = 10, maxNeuronsPerLayer = 10, maxWeightsPerNeuron = 10, maxActivatorsPerNeuron = 10

    init() {
        decoder = StrandDecoder(parsers: parsers, translators: translators)
        parsers.setDecoder(decoder: decoder)
        
        for _ in 0..<maxLayers {
            decoderTestInput += "L."

            // So we can chop off the most recent neuron count
            decoderTestInput += "I(0)"
            for neuronSS in -1..<maxNeuronsPerLayer {
                let withNeuronCountRemoved = decoderTestInput.dropFirst(5)
                decoderTestInput = String(withNeuronCountRemoved) + "I(\(neuronSS))"
            }
        }
    }
    
    func testDecoderExpectingOneEmptyLayer() {
        for string in TestDecoderInput.oneEmptyLayerStrands {
            print("Decoding '\(string)'")
            decoder.setInput(to: string).decode()
            expectSingleEmptyLayer()
            expectEndOfStrand()
        }
    }
}

extension TestDecoder {
    func expectSingleEmptyLayer() {
        if translators.layerStack.count != 1
        { Utilities.clobbered("Expected exactly one layer; got \(translators.layerStack.count)"); return }
        
        if translators.layerStack.last!.neurons.isMeaty
        { Utilities.clobbered("Expected no neurons; got \(translators.layerStack.last!.neurons.count)"); return }
    }
    
    func testDecodeSingleLayer() {
        decoder.setInput(to: "L.").decode()
        expectEndOfStrand()

        if translators.layerStack.count != 1
        { Utilities.clobbered("Expected exactly one layer; got \(translators.layerStack.count)"); return }
        
        if translators.layerStack.last!.neurons.isMeaty
        { Utilities.clobbered("Found neurons; no neurons expected"); return }
    }
    
    func testDecodeSingleLayerZeroNeurons() {
        decoder.setInput(to: "L.I(0).").decode()
        expectEndOfStrand()

        guard let newestLayer = translators.layerStack.last else
        { Utilities.clobbered("Huh? Layers count == 0? It worked on the first pass."); return }
        
        if newestLayer.neurons.isMeaty {
            Utilities.clobbered("Expected exactly one neuron; got \(newestLayer.neurons.count)"); return
        }
    }
    
    func expectEndOfStrand() {
        
        if !translators.reachedEndOfStrand
        { Utilities.clobbered("End of strand expected but not reached"); return }
    }
    
    func testDecodeSingleLayerOneNeuron() {
        decoder.setInput(to: "L.I(1).N.").decode()
        expectOneLayerOneEmptyNeuron()
    }
    
    func testDecodeSingleLayerOneNeuronOneZeroInt() {
        decoder.setInput(to: "L.I(1).N.I(0).").decode()
        expectOneLayerOneEmptyNeuron()
    }
    
    func expectOneLayerOneEmptyNeuron() {
        guard let newestLayer = translators.layerStack.last else
        { Utilities.clobbered("Huh? Layers count == 0? It worked on the first pass."); return }
        
        if newestLayer.neurons.count != 1 {
            Utilities.clobbered("Expected exactly one neuron; got \(newestLayer.neurons.count)"); return
        }
    }
    
    func testDecodeSingleLayerOneNeuronOneMeatyInt() {
        decoder.setInput(to: "L.I(1).N.I(1).").decode()
        expectOneLayerOneEmptyNeuron()
    }
}

extension Collection {
    var isMeaty: Bool { return !self.isEmpty }
}
