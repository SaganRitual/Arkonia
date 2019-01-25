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

class TDecoder: DecoderProtocol {
    var decodeState: DecodeState = .noLayer
    var inputGenome: Genome?
    var tNet: TNet!
    weak var layerUnderConstruction: TLayer?
    weak var neuronUnderConstruction: TNeuron?

    init() {
        precondition(ArkonCentralDark.decoder == nil)
        ArkonCentralDark.decoder = self
    }

    func decode() -> TNet {
        tNet = TNet()

        inputGenome!.makeIterator().forEach {
            switch decodeState {
            // Skip the diagnostics, or the decoder will create
            // a nice new layer for us, with a single neuron
            case .diagnostics: dispatch_noLayer($0)
            case .noLayer:     dispatch_noLayer($0)
            case .inLayer:     dispatch_inLayer($0)
            case .inNeuron:    dispatch_inNeuron($0)
            }
        }

        layerUnderConstruction?.finalizeNeuron()
        tNet.finalizeLayer()
        return tNet
    }

    func reset() { self.decodeState = .noLayer; tNet = nil }

    func setInput(to inputGenome: Genome) -> TDecoder {
        self.reset()
        self.inputGenome = inputGenome
        return self
    }
}

extension TDecoder {
    func dispatchValueGene(_ gene: Gene) {
        let neuron = neuronUnderConstruction !! { preconditionFailure() }

        switch gene.type {
        case .activator:
            let g = gene as? NeuronActivatorProtocol !! { preconditionFailure() }
            neuron.setActivator(g)

        case .bias:
            let g = gene as? NeuronBiasProtocol !! { preconditionFailure() }
            neuron.accumulateBias(g)

        case .downConnector:
            let g = gene as? NeuronDownConnectorProtocol  !! { preconditionFailure() }
            neuron.addDownConnector(g)

        case .upConnector:
            let g = gene as? NeuronUpConnectorProtocol  !! { preconditionFailure() }
            neuron.addUpConnector(g)

        default: preconditionFailure("Unknown gene \(gene)?")
        }
    }
}

extension TDecoder {

    func dispatch_noLayer(_ gene: Gene) {
        switch gene.type {
        case .layer:
            decodeState = .inLayer
            layerUnderConstruction = tNet.beginNewLayer()

        case .neuron:
            decodeState = .inNeuron
            layerUnderConstruction = tNet.beginNewLayer()
            neuronUnderConstruction = layerUnderConstruction!.beginNewNeuron()

        default:
            decodeState = .inNeuron
            layerUnderConstruction = tNet.beginNewLayer()
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
            layerUnderConstruction!.finalizeNeuron()
            tNet.finalizeLayer()
            layerUnderConstruction = tNet.beginNewLayer()

        case .neuron:
            decodeState = .inNeuron
            layerUnderConstruction!.finalizeNeuron()
            neuronUnderConstruction = layerUnderConstruction!.beginNewNeuron()

        default:
            return dispatchValueGene(gene)
        }
    }
}
