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
  

import XCTest

class DTDecode: XCTestCase {
    func testDecode() {
        #if DT_DECODE
        print("DT_DECODE is set")
        #endif

        let cLayers = 5
        let cSenseNeurons = 5
        let cMotorNeurons = 7
        ArkonCentral.selectionControls.cLayersInStarter = cLayers
        ArkonCentral.selectionControls.cSenseNeurons = cSenseNeurons
        ArkonCentral.selectionControls.cMotorNeurons = cMotorNeurons

        let g = Assembler.makePassThruGenome()
        var iter = g.makeIterator()
        let L = iter.filter { $0.type == .layer }

        iter = g.makeIterator()
        let N = iter.filter { $0.type == .neuron }

        iter = g.makeIterator()
        let Dv = iter.compactMap { ($0 as? gDownConnector)?.value }

        iter = g.makeIterator()
        let U = iter.compactMap { ($0 as? gUpConnector)?.weight }

        iter = g.makeIterator()
        let B = iter.filter { $0.type == .bias }

        iter = g.makeIterator()
        let A = iter.filter { $0.type == .activator }

        let cDownConnectors = Assembler.computeDownsPerNeuron(
            cSenseNeurons: cSenseNeurons, cMotorNeurons: cMotorNeurons
        )

        XCTAssertEqual(L.count, cLayers)
        XCTAssertEqual(N.count, cLayers * cSenseNeurons)

        // One activator function per neuron
        XCTAssertEqual(A.count, N.count)
        // One bias per neuron
        XCTAssertEqual(B.count, N.count)
        // One upConnector per neuron
        XCTAssertEqual(U.count, N.count)
        // downConnectors are a bit more involved to compute
        XCTAssertEqual(Dv.count, cDownConnectors)

        let decoder = TDecoder()
        let tNet = decoder.setInput(to: g).decode()
        XCTAssertEqual(tNet.layers.count, cLayers)

        let cNeurons = tNet.layers.map { $0.count }.reduce(0) { $0 + $1 }
        XCTAssertEqual(cNeurons, cLayers * cSenseNeurons)

        tNet.layers.forEach { layer in
            layer.neurons.forEach { neuron in
                XCTAssertEqual(neuron.activator, AFn.FunctionName.boundidentity)
                XCTAssertEqual(neuron.bias, 0.0)
                XCTAssertEqual(neuron.upConnectors.count, 1)
            }
        }

        // One activator function per neuron
        let cActivators = tNet.layers.map { $0.count }.reduce(0) { $0 + $1 }
        XCTAssertEqual(cActivators, N.count)
        // One bias per neuron
        XCTAssertEqual(B.count, N.count)
        // One upConnector per neuron
        XCTAssertEqual(U.count, N.count)
        // downConnectors are a bit more involved to compute
        XCTAssertEqual(Dv.count, cDownConnectors)

        let kDriver = KDriver(tNet: tNet)
        kDriver.drive()
    }

//    func testPerformanceExample() {
//        // This is an example of a performance test case.
//        self.measure {
//            // Put the code you want to measure the time of here.
//        }
//    }

}
