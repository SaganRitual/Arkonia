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

enum DecodeState {
    case diagnostics, inLayer, inNeuron, noLayer
}

class FDecoder: DecoderProtocol {
    var currentNeuronIsMeaty = false
    var decodeState: DecodeState = .noLayer
    var inputGenome: Genome?
    var fNet: FNet!
    weak var layerUnderConstruction: FLayer?
    weak var neuronUnderConstruction: FNeuron?

    var counter = 0

    init() {
        precondition(ArkonCentralDark.decoder == nil)
        ArkonCentralDark.decoder = self
    }

    func decode(_ inputGenome: GenomeProtocol) -> FNetProtocol? {
        fNet = FNet()

        self.inputGenome = nok(inputGenome as? Genome)
        self.inputGenome!.makeIterator().forEach { g in let gene = nok(g as? Gene)
            switch decodeState {
            case .diagnostics: dispatch_noLayer(gene)
            case .noLayer:     dispatch_noLayer(gene)
            case .inLayer:     dispatch_inLayer(gene)
            case .inNeuron:    dispatch_inNeuron(gene)
            }
        }

        defer { reset() }
        layerUnderConstruction?.finalizeNeuron()
        fNet.finalizeLayer()
        return fNet.subjectSurvived() ? fNet : nil
    }

    func reset() { self.decodeState = .noLayer; fNet = nil }

    func setInputGenome(_ inputGenome: GenomeProtocol) -> DecoderProtocol {
        if self.inputGenome == nil { self.inputGenome = Genome() }
        else { self.inputGenome!.releaseFull_() }

        let ig = nok(inputGenome as? Genome)
        ig.releaseFull_(to: self.inputGenome!)
//        self.inputGenome!.dump()
        return self
    }
}

extension FDecoder {
    func dispatchValueGene(_ gene: Gene) {
        let neuron = neuronUnderConstruction !! { preconditionFailure() }

        switch gene.type {
        case .activator:
            let g = gene as? gActivatorFunction !! { preconditionFailure(String(describing: gene.type)) }
            neuron.setActivator(g)

        case .bias:
            let g = gene as? gBias !! { preconditionFailure(String(describing: gene.type)) }
            neuron.accumulateBias(g)

        case .downConnector:
            guard let g = gene as? gDownConnector else {
                print(String(describing: gene))
                preconditionFailure("\(type(of: gene))")
            }

            neuron.addDownConnector(g)

        case .upConnector:
            let g = gene as? gUpConnector  !! { preconditionFailure(String(describing: gene.type)) }
            neuron.addUpConnector(g)

        default: break; //print("Unknown gene \(gene)?")
        }
    }
}

extension FDecoder {

    func dispatch_noLayer(_ gene: Gene) {
        switch gene.type {
        case .layer:
            decodeState = .inLayer
            layerUnderConstruction = fNet.beginNewLayer()

        case .neuron:
            decodeState = .inNeuron
            layerUnderConstruction = fNet.beginNewLayer()
            neuronUnderConstruction = layerUnderConstruction!.beginNewNeuron()

        default:
            decodeState = .inNeuron
            layerUnderConstruction = fNet.beginNewLayer()
            neuronUnderConstruction = layerUnderConstruction!.beginNewNeuron()

            dispatchValueGene(gene)
        }
    }

    func dispatch_inLayer(_ gene: Gene) {
        switch gene.type {
        case .layer:
            // Got another layer marker, but it would
            // cause this one to be empty. Just ignore it.
            decodeState = .inLayer

        case .neuron:
            decodeState = .inNeuron
            neuronUnderConstruction = layerUnderConstruction!.beginNewNeuron()

        default:
            decodeState = .inNeuron
            neuronUnderConstruction = layerUnderConstruction!.beginNewNeuron()

            dispatchValueGene(gene)
        }
    }

    func dispatch_inNeuron(_ gene: Gene) {
        switch gene.type {
        case .layer:
            decodeState = .inLayer
            layerUnderConstruction?.finalizeNeuron()
            fNet.finalizeLayer()
            layerUnderConstruction = fNet.beginNewLayer()

        case .neuron:
            // Got another neuron marker, but it would
            // cause this one to be empty. Just ignore it.
            if currentNeuronIsMeaty {
                currentNeuronIsMeaty = false

                decodeState = .inNeuron
                layerUnderConstruction!.finalizeNeuron()
                neuronUnderConstruction = layerUnderConstruction!.beginNewNeuron()
            }

        default:
            currentNeuronIsMeaty = true
            return dispatchValueGene(gene)
        }
    }
}