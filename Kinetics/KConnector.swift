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

struct KConnector {
    var connectingNeuron: KNeuron!

    init(_ connectingNeuron: KNeuron) {
        self.connectingNeuron = connectingNeuron
    }

    func selectOutputs(from upperLayer: KLayer) -> [Int] {
        // Check for empty and grab the last entry at the same time
        guard let startingTarget = connectingNeuron.upConnectors.last else { return [] }
        var channelIx = startingTarget.channel.channel

        let upperNeurons = upperLayer.neurons

        let fIter = upperNeurons.compactMap({ ($0.relay?.isOperational ?? false) ? $0 : nil })
        if fIter.isEmpty { return [] }

        let rIter = fIter.reversed()

        var inputIDs = [Int]()

        while !connectingNeuron.upConnectors.isEmpty {
            let target = connectingNeuron.upConnectors.removeLast()

             // save weight for the signaling step
            connectingNeuron.weights.append(target.weight.weight)
//            print("uuu \(connectingNeuron)")

            let inputNeuron: KNeuron = {
                if channelIx >= 0 {
                    defer { channelIx += 1 }
                    return fIter[channelIx % fIter.count]
                } else {
                    defer { channelIx -= 1 }
                    let i = rIter.index(rIter.startIndex, offsetBy: -channelIx % rIter.count)
                    return rIter[i]
                }
            }()

            inputIDs.append(inputNeuron.id.myID)
        }

//        print("select outputs for \(connectingNeuron.id)", inputIDs)
        return inputIDs
    }
}
