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

#if EXPERIMENTAL
print("Experimental")
#endif

#if RUN_DARK
print("Run dark")
#endif

enum ArkonCentral {
    enum sel {
        static let cSenseNeurons = 5
        static let cMotorNeurons = 5
    }
}

enum Manipulator {

static public func makePassThruGenome(cLayers: Int) -> Genome {
    var dag = Genome()
    for _ in 0..<cLayers - 1 {
        dag += makeOneLayer(cNeurons: ArkonCentral.sel.cSenseNeurons)
    }

    dag += makeLastHiddenLayer(
        cNeurons: ArkonCentral.sel.cSenseNeurons, oNeurons: ArkonCentral.sel.cMotorNeurons
    )

    return dag
}

static func baseNeuronSnippet(channel: Int) -> Genome {
    return Genome([
        gNeuron(),
        gActivatorFunction(.boundidentity),
        gUpConnector((1.0, channel)),
        gBias(0.0)
    ])
}

static private func makeLastHiddenLayer(cNeurons: Int, oNeurons: Int) -> Genome {
    var protoGenome = Genome(gLayer())

    var downsPerNeuron = oNeurons / cNeurons
    if downsPerNeuron == 0 { downsPerNeuron = cNeurons / oNeurons }

    var remainder = oNeurons * cNeurons - downsPerNeuron

    var channel = (100 / cNeurons) + cNeurons
    for c in 0..<cNeurons {
        protoGenome += baseNeuronSnippet(channel: c)

        let r = remainder > 0 ? 1 : 0
        remainder -= r  // Stops at zero, because I'm so clever

        for _ in 0..<(downsPerNeuron + r) {
            protoGenome += gDownConnector(channel)
            channel += 1
        }
    }

    return protoGenome
}

static private func makeOneLayer(cNeurons: Int) -> Genome {
    return Genome(gLayer()) + (0..<cNeurons).map { baseNeuronSnippet(channel: $0) }
}

}

//typealias Genome = Genome<Gene>
//var theGenome = Manipulator.makePassThruGenome(cLayers: 7)
//
////theGenome.append(gBias(42.42))
////theGenome.append(gActivatorFunction(.arctan))
////theGenome.append(gUpConnector((1.0, -17)))
////theGenome.append(gDownConnector(7))
//
//theGenome.makeIterator().forEach { print($0) }

