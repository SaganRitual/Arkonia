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

enum Assembler {
    static public func makeRandomGenome(cGenes: Int) -> [GeneProtocol] {
        let genome = (0..<cGenes).map { _ in GeneCore.makeRandomGene() }

        return genome
    }

    static var bias = 1.0
    static func baseNeuronSnippet(channel: Int) -> [GeneProtocol] {
        bias *= -1

        var transport: [GeneProtocol] = [
            gNeuron(), gActivatorFunction(.boundidentity), gBias(bias)
        ]

        transport += (0..<ArkonCentralDark.selectionControls.cSenseNeurons).map {
            gUpConnector(($0, 1.0))
         }

        return transport
    }

    static private func makeOneLayer(cNeurons: Int) -> [GeneProtocol] {
        let marker = [gLayer()]
        let neurons = (0..<cNeurons).flatMap { channel in
            baseNeuronSnippet(channel: channel)
        }

        return marker + neurons
    }

}
