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
    static public func makePassThruGenome() -> Genome {
        let cMotorNeurons = ArkonCentralDark.selectionControls.cMotorNeurons
        let cSenseNeurons = ArkonCentralDark.selectionControls.cSenseNeurons
        let cLayers = ArkonCentralDark.selectionControls.cLayersInStarter

        let p = Genome((0..<(cLayers - 1)).map { _ in return makeOneLayer(cNeurons: cSenseNeurons) })
        let h = makeLastHiddenLayer(cSenseNeurons: cSenseNeurons, cMotorNeurons: cMotorNeurons)

        p.asslink(h)
        return p
    }

    static var bias = 1.0
    static func baseNeuronSnippet(channel: Int) -> Segment {
        bias *= -1

        return Segment([
            gNeuron(),
            gActivatorFunction(.boundidentity),
            gUpConnector((channel, 1.0)),
            gBias(bias)
        ])
    }

    static func computeDownsPerNeuron(cSenseNeurons: Int, cMotorNeurons: Int) -> Int {
        // All this hoop-jumping is for when the number of inputs and the number of
        // outputs differ. The idea is to make sure we generate enough down connectors
        // for a passthru genome to connect at least once to all the motor neurons.
        // Example:
        //
        // args -> cSenseNeurons = 6, cMotorNeurons = 27...
        var downsPerNeuron = cMotorNeurons / cSenseNeurons

        //  -> downsPerNeuron = 4...
        if downsPerNeuron == 0 { downsPerNeuron = cSenseNeurons / cMotorNeurons }

        //  -> remainder = 3
        let remainder = cMotorNeurons * cSenseNeurons - downsPerNeuron

        //  -> downsPerNeuron = 5
        if remainder > 0 { downsPerNeuron += 1 }

        return downsPerNeuron
    }

    static private func makeLastHiddenLayer(cSenseNeurons: Int, cMotorNeurons: Int) -> Segment {
        let segment = Segment(gLayer())

        let downsPerNeuron = computeDownsPerNeuron(
            cSenseNeurons: cSenseNeurons, cMotorNeurons: cMotorNeurons
        )

        // (continuing the example in computeDownsPerNeuron()
        //  -> channel = 22
        var channel = (100 / cSenseNeurons) + cSenseNeurons

        //  -> Loop 6 times
        for c in 0..<cSenseNeurons {
            //  -> channel == c tells each neuron to connect to the neuron directly above
            segment.asslink(baseNeuronSnippet(channel: c))
        }

        //  -> 0..<4
        for _ in 0..<downsPerNeuron {
            //  -> First down connector goes straight down. Others
            // go to the right of that one, wrapping around to the
            // first neuron in the upper layer if necessary.
            let g = gDownConnector(channel)
            segment.asslink(g)
            channel += 1
        }

        return segment
    }

    static private func makeOneLayer(cNeurons: Int) -> Segment {
        let segment = Segment(gLayer())
        segment.asslink((0..<cNeurons).map { baseNeuronSnippet(channel: $0) })
        return segment
    }

}
