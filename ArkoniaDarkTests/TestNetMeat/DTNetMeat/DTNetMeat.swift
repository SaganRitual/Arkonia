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

class DTNetMeat: XCTestCase {
    let cLayers = 5
    let dummyRelay = RRelay(KIdentifier("Dummy", [42, 42], 42))
    let rGridID = KIdentifier("Relay Test", 0)
    var rGrid: RGrid!
    var wGrid: WGrid!

    let senseSpecs = [
        ConnectionSpec(targets: [GridXY(0, -1)]),
        ConnectionSpec(targets: [GridXY(1, -2)]),
        ConnectionSpec(targets: [GridXY(2, -3)]),
        ConnectionSpec(targets: [GridXY(3, -4)]),
        ConnectionSpec(targets: [GridXY(4, -5)])
    ]

    override func tearDown() {
        rGrid = nil
        wGrid = nil
    }

    class TUpConnector: NeuronUpConnectorProtocol {
        var value: UpConnectorValue
        init(channel: Int, weight: Double) { value = (channel, weight) }
    }

    struct MockDownConnector: NeuronDownConnectorProtocol {
        var value: Int
        init(_ value: Int) { self.value = value }
    }

    private func buildFNet(cLayers: Int, cNeurons: Int) -> FNet {
        let net = FNet()

        for layerSS in 0..<cLayers {
            let layer = net.beginNewLayer()

            var neuron: FNeuron!
            for channel in 0..<cNeurons {
                neuron = layer.beginNewNeuron()
                neuron.addUpConnector(TUpConnector(channel: channel, weight: 1.0))

                if layerSS == cLayers - 1 {
                    neuron.addDownConnector(MockDownConnector(channel))
                }

                layer.finalizeNeuron()
            }

            net.finalizeLayer()
        }

        return net
    }

    let testOldTestCLayers = 5
    let testOldTestCNeurons = 5
    func testOldTest() {
        let fNet = buildFNet(cLayers: testOldTestCLayers, cNeurons: testOldTestCNeurons)
        let driver = KSignalDriver(idNumber: 0, fNet: fNet)

        driver.drive(sensoryInputs: Array(repeating: 1.0, count: testOldTestCNeurons))

        XCTAssertEqual(driver.motorOutputs,
            Array(repeating: 1.0, count: ArkonCentralDark.selectionControls.cMotorNeurons
        ))
    }

//    func testConnectionsOn2x2() {
//        let gridHeight = 2
//        let gridWidth = 2
//
//        setupGrid(gridWidth: gridWidth, gridHeight: gridHeight)
//
//        rGrid[1][0]!.inputRelays = rGrid[0].relays.map { $0! }
//        rGrid[1][1]!.inputRelays = rGrid[0].relays.map { $0! }
//
//        // Nothing should change when we connect the layers
//        wGrid.layers.forEach { $0.relays.forEach { XCTAssertNotNil($0) } }
//
//        var anchors: RLayer? = rGrid[rGrid.layers.count - 1]
//        rGrid = nil
//
//        // Nothing should change when we decouple the scaffolding
//        wGrid.layers.forEach { $0.relays.forEach { XCTAssertNotNil($0) } }
//
//        // Delete [1][1]; no cascade should occur, because [1][0] still
//        // has refs to layer 0
//        anchors![1] = nil
//        XCTAssertNotNil(wGrid[0][0].relay)
//        XCTAssertNotNil(wGrid[0][1].relay)
//        XCTAssertNotNil(wGrid[1][0].relay)
//        XCTAssertNil(wGrid[1][1].relay)
//
//        // Disconnect [1][0] from [0][0]
//        wGrid[1][0].relay!.inputRelays[0] = dummyRelay
//        XCTAssertNil(wGrid[0][0].relay)
//        XCTAssertNotNil(wGrid[0][1].relay)
//        XCTAssertNotNil(wGrid[1][0].relay)
//
//        // Delete [1][0], should also delete [0][1]
//        anchors![0] = nil
//        XCTAssertNil(wGrid[0][1].relay)
//        XCTAssertNil(wGrid[1][0].relay)
//
//        anchors = nil
//    }
//
//    func testConnectionsOn3x3() {
//        let gridHeight = 3
//        let gridWidth = 3
//
//        setupGrid(gridWidth: gridWidth, gridHeight: gridHeight)
//
//        // Connect everyone to everyone else
//        rGrid[2][0]!.inputRelays = rGrid[1].relays.map { $0! }
//        rGrid[2][1]!.inputRelays = rGrid[1].relays.map { $0! }
//        rGrid[2][2]!.inputRelays = rGrid[1].relays.map { $0! }
//
//        rGrid[1][0]!.inputRelays = rGrid[0].relays.map { $0! }
//        rGrid[1][1]!.inputRelays = rGrid[0].relays.map { $0! }
//        rGrid[1][2]!.inputRelays = rGrid[0].relays.map { $0! }
//
//        // Nothing should change when we connect the layers
//        wGrid.layers.forEach { $0.relays.forEach { XCTAssertNotNil($0) } }
//
//        var anchors: RLayer? = rGrid[rGrid.layers.count - 1]
//        rGrid = nil
//
//        // Nothing should change when we decouple the scaffolding
//        wGrid.layers.forEach { $0.relays.forEach { XCTAssertNotNil($0) } }
//
//        disconnectChannel(1, fromLayer: 2)
//        XCTAssertNotNil(wGrid[0][0].relay)
//        XCTAssertNotNil(wGrid[0][1].relay)
//        XCTAssertNotNil(wGrid[0][2].relay)
//
//        XCTAssertNotNil(wGrid[1][0].relay)
//        XCTAssertNil   (wGrid[1][1].relay)
//        XCTAssertNotNil(wGrid[1][2].relay)
//
//        // Delete [2][1]; no cascade should occur, because
//        // [2][0] and [2][2] still have references
//        anchors![1] = nil
//        XCTAssertNotNil(wGrid[0][0].relay)
//        XCTAssertNotNil(wGrid[0][1].relay)
//        XCTAssertNotNil(wGrid[0][2].relay)
//
//        XCTAssertNotNil(wGrid[1][0].relay)
//        XCTAssertNil   (wGrid[1][1].relay)
//        XCTAssertNotNil(wGrid[1][2].relay)
//
//        // Disconnect [1][0] from [0][0], no change: [1][2] still has ref
//        wGrid[1][0].relay!.inputRelays[0] = dummyRelay
//        XCTAssertNotNil(wGrid[0][0].relay)
//        XCTAssertNotNil(wGrid[0][1].relay)
//        XCTAssertNotNil(wGrid[0][2].relay)
//
//        XCTAssertNotNil(wGrid[1][0].relay)
//        XCTAssertNil   (wGrid[1][1].relay)
//        XCTAssertNotNil(wGrid[1][2].relay)
//
//        // Disconnect [2][0] from [1][0], no  change; other layer 2 have ref
//        wGrid[2][0].relay!.inputRelays[0] = dummyRelay
//        XCTAssertNotNil(wGrid[0][0].relay)
//        XCTAssertNotNil(wGrid[0][1].relay)
//        XCTAssertNotNil(wGrid[0][2].relay)
//
//        XCTAssertNotNil(wGrid[1][0].relay)
//        XCTAssertNil   (wGrid[1][1].relay)
//        XCTAssertNotNil(wGrid[1][2].relay)
//
//        // Delete [1][2], should also drop [0][0]
//        disconnectChannel(2, fromLayer: 2)
//        XCTAssertNil   (wGrid[0][0].relay)
//        XCTAssertNotNil(wGrid[0][1].relay)
//        XCTAssertNotNil(wGrid[0][2].relay)
//
//        XCTAssertNotNil(wGrid[1][0].relay)
//        XCTAssertNil   (wGrid[1][1].relay)
//        XCTAssertNil   (wGrid[1][2].relay)
//
//        anchors = nil
//    }
}

extension DTNetMeat {

    private func disconnectChannel(_ channel: Int, fromLayer: Int) {
        wGrid[fromLayer].relays.forEach { wRelay in
            wRelay.relay?.inputRelays[channel] = dummyRelay
        }
    }

    private func setupGrid(gridWidth: Int, gridHeight: Int) {
        rGrid = RGrid(rGridID, gridWidth: gridWidth, gridHeight: gridHeight)
        wGrid = WGrid(rGrid)

        wGrid.layers.forEach { $0.relays.forEach { XCTAssertNotNil($0) } }
    }

}
