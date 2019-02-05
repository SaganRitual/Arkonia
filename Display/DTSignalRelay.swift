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

// swiftlint:disable function_body_length

class DTSignalRelay: XCTestCase {
    let dummyRelay = RRelay(KIdentifier("Dummy", [42, 42], 42))
    let rGridID = KIdentifier("Relay Test", 0)
    var rGrid: RGrid!
    var wGrid: WGrid!

    override func tearDown() {
        rGrid = nil
        wGrid = nil
    }

    func testConnectionsOn2x2() {
        let gridHeight = 2
        let gridWidth = 2

        setupGrid(gridWidth: gridWidth, gridHeight: gridHeight)

        rGrid[1][0]!.inputRelays = rGrid[0].relays.map { $0! }
        rGrid[1][1]!.inputRelays = rGrid[0].relays.map { $0! }

        // Nothing should change when we connect the layers
        wGrid.layers.forEach { $0.relays.forEach { XCTAssertNotNil($0) } }

        var anchors: RLayer? = rGrid[rGrid.layers.count - 1]
        rGrid = nil

        // Nothing should change when we decouple the scaffolding
        wGrid.layers.forEach { $0.relays.forEach { XCTAssertNotNil($0) } }

        // Delete [1][1]; no cascade should occur, because [1][0] still
        // has refs to layer 0
        anchors![1] = nil
        XCTAssertNotNil(wGrid[0][0].relay)
        XCTAssertNotNil(wGrid[0][1].relay)
        XCTAssertNotNil(wGrid[1][0].relay)
        XCTAssertNil(wGrid[1][1].relay)

        // Disconnect [1][0] from [0][0]
        wGrid[1][0].relay!.inputRelays[0] = dummyRelay
        XCTAssertNil(wGrid[0][0].relay)
        XCTAssertNotNil(wGrid[0][1].relay)
        XCTAssertNotNil(wGrid[1][0].relay)

        // Delete [1][0], should also delete [0][1]
        anchors![0] = nil
        XCTAssertNil(wGrid[0][1].relay)
        XCTAssertNil(wGrid[1][0].relay)

        anchors = nil
    }

    func testConnectionsOn3x3() {
        let gridHeight = 3
        let gridWidth = 3

        setupGrid(gridWidth: gridWidth, gridHeight: gridHeight)

        // Connect everyone to everyone else
        rGrid[2][0]!.inputRelays = rGrid[1].relays.map { $0! }
        rGrid[2][1]!.inputRelays = rGrid[1].relays.map { $0! }
        rGrid[2][2]!.inputRelays = rGrid[1].relays.map { $0! }

        rGrid[1][0]!.inputRelays = rGrid[0].relays.map { $0! }
        rGrid[1][1]!.inputRelays = rGrid[0].relays.map { $0! }
        rGrid[1][2]!.inputRelays = rGrid[0].relays.map { $0! }

        // Nothing should change when we connect the layers
        wGrid.layers.forEach { $0.relays.forEach { XCTAssertNotNil($0) } }

        var anchors: RLayer? = rGrid[rGrid.layers.count - 1]
        rGrid = nil

        // Nothing should change when we decouple the scaffolding
        wGrid.layers.forEach { $0.relays.forEach { XCTAssertNotNil($0) } }

        disconnectChannel(1, fromLayer: 2)
        XCTAssertNotNil(wGrid[0][0].relay)
        XCTAssertNotNil(wGrid[0][1].relay)
        XCTAssertNotNil(wGrid[0][2].relay)

        XCTAssertNotNil(wGrid[1][0].relay)
        XCTAssertNil   (wGrid[1][1].relay)
        XCTAssertNotNil(wGrid[1][2].relay)

        // Delete [2][1]; no cascade should occur, because
        // [2][0] and [2][2] still have references
        anchors![1] = nil
        XCTAssertNotNil(wGrid[0][0].relay)
        XCTAssertNotNil(wGrid[0][1].relay)
        XCTAssertNotNil(wGrid[0][2].relay)

        XCTAssertNotNil(wGrid[1][0].relay)
        XCTAssertNil   (wGrid[1][1].relay)
        XCTAssertNotNil(wGrid[1][2].relay)

        // Disconnect [1][0] from [0][0], no change: [1][2] still has ref
        wGrid[1][0].relay!.inputRelays[0] = dummyRelay
        XCTAssertNotNil(wGrid[0][0].relay)
        XCTAssertNotNil(wGrid[0][1].relay)
        XCTAssertNotNil(wGrid[0][2].relay)

        XCTAssertNotNil(wGrid[1][0].relay)
        XCTAssertNil   (wGrid[1][1].relay)
        XCTAssertNotNil(wGrid[1][2].relay)

        // Disconnect [2][0] from [1][0], no  change; other layer 2 have ref
        wGrid[2][0].relay!.inputRelays[0] = dummyRelay
        XCTAssertNotNil(wGrid[0][0].relay)
        XCTAssertNotNil(wGrid[0][1].relay)
        XCTAssertNotNil(wGrid[0][2].relay)

        XCTAssertNotNil(wGrid[1][0].relay)
        XCTAssertNil   (wGrid[1][1].relay)
        XCTAssertNotNil(wGrid[1][2].relay)

        // Delete [1][2], should also drop [0][0]
        disconnectChannel(2, fromLayer: 2)
        XCTAssertNil   (wGrid[0][0].relay)
        XCTAssertNotNil(wGrid[0][1].relay)
        XCTAssertNotNil(wGrid[0][2].relay)

        XCTAssertNotNil(wGrid[1][0].relay)
        XCTAssertNil   (wGrid[1][1].relay)
        XCTAssertNil   (wGrid[1][2].relay)

        anchors = nil
    }

    func test5x5() {
        let gridHeight = 5
        let gridWidth = 5

        setupGrid(gridWidth: gridWidth, gridHeight: gridHeight)

        rGrid[4][2]!.inputRelays.append(rGrid[3][0]!)
        rGrid[4][2]!.inputRelays.append(rGrid[3][1]!)
        rGrid[4][2]!.inputRelays.append(rGrid[3][2]!)

        rGrid[3][0]!.inputRelays.append(rGrid[2][0]!)
        rGrid[3][1]!.inputRelays.append(rGrid[2][0]!)
        rGrid[3][2]!.inputRelays.append(rGrid[2][0]!)

        rGrid[2][0]!.inputRelays.append(rGrid[1][2]!)
        rGrid[2][0]!.inputRelays.append(rGrid[1][3]!)

        rGrid[1][2]!.inputRelays.append(rGrid[0][1]!)
        rGrid[1][2]!.inputRelays.append(rGrid[0][3]!)

        rGrid[1][3]!.inputRelays.append(rGrid[0][0]!)
        rGrid[1][3]!.inputRelays.append(rGrid[0][4]!)

        var anchors: RLayer? = rGrid[rGrid.layers.count - 1]
        rGrid = nil

        var expectedConnections = """

(<)(<)(](<)(<)
(](](:T:T)(:T:T)(]
(:T:T)(](](](]
(:T)(:T)(:T)(](]
(<)(<)(:T:T:T)(<)(<)
"""
        XCTAssertEqual(connectionsMap, expectedConnections)

        // Disconnect [1][2] from channel 0; should cause [0][1] to go away
        wGrid[1][2].relay!.inputRelays[0] = dummyRelay
        expectedConnections = """

(<)(](](<)(<)
(](](:F:T)(:T:T)(]
(:T:T)(](](](]
(:T)(:T)(:T)(](]
(<)(<)(:T:T:T)(<)(<)
"""
        XCTAssertEqual(connectionsMap, expectedConnections)
        XCTAssertNil(wGrid[0][1].relay)

        // Disconnect [2][0] from channel 0; should cause [1][2], [0][3] to go away
        wGrid[2][0].relay!.inputRelays[0] = dummyRelay
        expectedConnections = """

(<)(](](](<)
(](](](:T:T)(]
(:F:T)(](](](]
(:T)(:T)(:T)(](]
(<)(<)(:T:T:T)(<)(<)
"""
        XCTAssertEqual(connectionsMap, expectedConnections)

        // Disconnect from [3][0], which should then go away
        wGrid[4][2].relay!.inputRelays[0] = dummyRelay
        expectedConnections = """

(<)(](](](<)
(](](](:T:T)(]
(:F:T)(](](](]
(](:T)(:T)(](]
(<)(<)(:F:T:T)(<)(<)
"""
        XCTAssertEqual(connectionsMap, expectedConnections)

        // Disconnect from [3][1], which should also go away
        wGrid[4][2].relay!.inputRelays[1] = dummyRelay
        expectedConnections = """

(<)(](](](<)
(](](](:T:T)(]
(:F:T)(](](](]
(](](:T)(](]
(<)(<)(:F:F:T)(<)(<)
"""
        XCTAssertEqual(connectionsMap, expectedConnections)

        // Last connection; the whole grid should go away, except the anchor layer
        wGrid[4][2].relay!.inputRelays[2] = dummyRelay
        expectedConnections = """

(](](](](]
(](](](](]
(](](](](]
(](](](](]
(<)(<)(:F:F:F)(<)(<)
"""
        XCTAssertEqual(connectionsMap, expectedConnections)

        // And finally, the anchor layer
        anchors = nil
        expectedConnections = """

(](](](](]
(](](](](]
(](](](](]
(](](](](]
(](](](](]
"""
        XCTAssertEqual(connectionsMap, expectedConnections)
        XCTAssertNil(anchors, "Compiler complains about anchors being unread")
    }

    func testForSmokeInLayers() {
        let gridHeight = 1
        let gridWidth = 5

        setupGrid(gridWidth: gridWidth, gridHeight: gridHeight)

        rGrid[0].relays.enumerated().forEach { ss, _ in rGrid[0][ss] = nil }
        wGrid[0].relays.enumerated().forEach { ss, _ in XCTAssertNil(wGrid[0][ss].relay) }
    }

    func tesbSignalRelay() {
    }

    func testSwitches() {
        #if K_RUN_DT_SIGNAL_RELAY
        print("K_RUN_DT_SIGNAL_RELAY!")
        #else
        XCTAssert(false)
        #endif
    }

    func testWhetherOptionalsHaveGoneWonkyAgain() {
        let gridHeight = 5
        let gridWidth = 5

        setupGrid(gridWidth: gridWidth, gridHeight: gridHeight)

        // Poke holes randomly and make sure the relays destruct as expected.
        // Xx Xx Xx Xx Xx
        // Xx Xx Xx Xx Xx
        // Xx Xx Xx Xx Xx
        // Xx Xx Xx Xx Xx
        // Xx Xx Xx Xx Xx
        [
            (2, 2), (4, 4), (0, 1), (1, 4), (3, 0),
            (1, 3), (1, 0), (4, 0), (0, 0), (2, 0),
            (2, 1), (2, 3), (2, 4), (4, 1), (3, 2),
            (1, 2), (0, 3), (0, 4), (3, 1), (3, 3),
            (3, 4), (0, 3), (4, 3), (1, 1), (0, 2)
            ].forEach { x, y in

                rGrid[y][x] = nil
                XCTAssert(wGrid[y][x].relay == nil)
        }
    }
}

extension DTSignalRelay {

    var connectionsMap: String {
        func channels(_ layer: Int, _ relay: Int) -> String {
            var result = "("

            guard let sink = wGrid[layer][relay].relay else { return result + "]" }

            if sink.inputRelays.isEmpty { return result + "<)" }

            for channel in 0..<sink.inputRelays.count {
                result += ":" + ((sink.inputRelays[channel].id == dummyRelay.id) ? "F" : "T")
            }

            return result + ")"
        }

        func relays(_ layer: Int) -> String {
            return "\n" + (0..<wGrid[layer].relays.count).map { relay in channels(layer, relay) }.joined()
        }

        return String((0..<wGrid.layers.count).map { layer in relays(layer) }.joined()).uppercased()
    }

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
// swiftlint:enable function_body_length
