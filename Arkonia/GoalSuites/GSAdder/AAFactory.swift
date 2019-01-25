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

class AAFactory: GSFactory {
    override var description: String { return "AAFactory; functioning within standard operational parameters" }

    override public func makeArkon(genome: GenomeSlice, mutate: Bool = true) -> AASubject? {
        guard let tNet = makeNet(genome: genome, mutate: mutate) else { return nil }

        let a = AASubject(genome: genomeWorkspace[...])
        a.postInit(tNet: tNet)
        return a
    }

    override func postInit(suite: GSGoalSuite) {
        self.suite = suite

        ArkonCentralDark.selectionControls.cMotorNeurons = 5
        ArkonCentralDark.selectionControls.cSenseNeurons = 5
        ArkonCentralDark.selectionControls.cLayersInStarter = 5

        let h = ArkonCentralDark.selectionControls.cLayersInStarter
        GSFactory.aboriginalGenome = makePassThruGenome(cLayers: h)
    }

    private func makePassThruGenome(cLayers: Int) -> Genome {
        var dag = Genome()
        for _ in 0..<cLayers {
            dag = makeOneLayer(dag, hmNeurons: ArkonCentralDark.selectionControls.cSenseNeurons)
        }

//        dag += "L_N_"
//        dag += "A(\(true))_F(identity)_W(b[\(1)]v[\(1)])_B(\(1))_"
//        dag += "A(\(true))_F(identity)_W(b[\(1)]v[\(1)])_B(\(-1))_"

        return dag
    }

    private func makeOneLayer(_ protoGenome_: Genome, hmNeurons: Int) -> Genome {
        var protoGenome = protoGenome_ + "L_"
        var bias = 1.0
        var scanRight = true
        for _ in 0..<hmNeurons {
            protoGenome += "N_A(\(scanRight))_F(identity)_W(b[\(1)]v[\(1)])_B(\(bias))_"
            bias *= -1
            scanRight = !scanRight
        }
        return protoGenome
    }

}
