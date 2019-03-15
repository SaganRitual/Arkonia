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

class FDecoder {
    static var shared: FDecoder!

    var cNeuronsInCurrentLayer = 0
    var currentNeuronIsMeaty = false
    var decodeState: DecodeState = .noLayer
    var fNet: FNet!
    weak var layerUnderConstruction: FLayer?
    weak var neuronUnderConstruction: FNeuron?

    func decode(_ inputGenome: [GeneProtocol]) -> FNet? {
        fNet = FNet()

        inputGenome.forEach { gene in
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

    func reset() {
        decodeState = .noLayer
        fNet = nil
        cNeuronsInCurrentLayer = 0
    }
}

extension FDecoder {
    func dispatchValueGene(_ gene: GeneProtocol) {
        let neuron = neuronUnderConstruction !! { preconditionFailure() }

        switch gene.core {
        case let .activator(functionName, _): neuron.setActivator(functionName)
        case let .double(bias, _):            neuron.accumulateBias(bias)
        case let .int(channel, _, _):         neuron.addDownConnector(channel)

        case let .upConnector(channel, _, weight, _):
            neuron.addUpConnector(UpConnectorValue(channel: channel, weight: weight))

        case .empty:
            preconditionFailure("Shouldn't get empty genes in this function")
        }
    }
}

extension FDecoder {

    func dispatch_noLayer(_ gene: GeneProtocol) {
        currentNeuronIsMeaty = false

        switch gene {
        case is gLayer:
            decodeState = .inLayer
            layerUnderConstruction = fNet.beginNewLayer()
            cNeuronsInCurrentLayer = 0

        case is gNeuron:
            decodeState = .inNeuron
            layerUnderConstruction = fNet.beginNewLayer()
            neuronUnderConstruction = layerUnderConstruction!.beginNewNeuron()
            cNeuronsInCurrentLayer = 1
            currentNeuronIsMeaty = false

        default:
            decodeState = .inNeuron
            layerUnderConstruction = fNet.beginNewLayer()
            neuronUnderConstruction = layerUnderConstruction!.beginNewNeuron()
            cNeuronsInCurrentLayer = 1

            dispatchValueGene(gene)
            currentNeuronIsMeaty = true
        }
    }

    func dispatch_inLayer(_ gene: GeneProtocol) {
        switch gene {
        case is gLayer:
            // Got another layer marker, but it would
            // cause this one to be empty, or have a single
            // neuron. Just ignore it and move to the next gene.
            if cNeuronsInCurrentLayer > 1 {
                decodeState = .inLayer
                cNeuronsInCurrentLayer = 0
                currentNeuronIsMeaty = false
            }

        case is gNeuron:
            decodeState = .inNeuron
            neuronUnderConstruction = layerUnderConstruction!.beginNewNeuron()
            cNeuronsInCurrentLayer += 1
            currentNeuronIsMeaty = false

        default:
            decodeState = .inNeuron

            neuronUnderConstruction = layerUnderConstruction!.beginNewNeuron()
            cNeuronsInCurrentLayer += 1

            dispatchValueGene(gene)
            currentNeuronIsMeaty = true
        }
    }

    func dispatch_inNeuron(_ gene: GeneProtocol) {
        switch gene {
        case is gLayer:
            // Got another layer marker, but it would
            // cause this one to be empty, or have a single
            // neuron. Just ignore it and move to the next gene.
            if cNeuronsInCurrentLayer > 1 {
                decodeState = .inLayer
                layerUnderConstruction?.finalizeNeuron()
                fNet.finalizeLayer()
                layerUnderConstruction = fNet.beginNewLayer()
                cNeuronsInCurrentLayer = 0
                currentNeuronIsMeaty = false
            }

        case is gNeuron:
            // Got another neuron marker, but it would
            // cause this one to be empty. Just ignore it.
            if currentNeuronIsMeaty {
                currentNeuronIsMeaty = false

                decodeState = .inNeuron
                layerUnderConstruction!.finalizeNeuron()
                neuronUnderConstruction = layerUnderConstruction!.beginNewNeuron()
            }

        default:
            // Pedantry--it's not meaty until we return from the dispatch
            defer { currentNeuronIsMeaty = true }
            return dispatchValueGene(gene)
        }
    }
}
