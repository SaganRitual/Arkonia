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
#if SIGNAL_GRID_DIAGNOSTICS
import Foundation

struct KConnector {
    let connectingNeuron: KNeuron

    init(_ connectingNeuron: KNeuron) {
        self.connectingNeuron = connectingNeuron
    }

    func selectOutputs(from upperLayer: KLayer) -> [Int] {
        // Check for empty and grab the last entry at the same time
        guard let startingTarget = connectingNeuron.upConnectors.last else { return [] }

        let upperNeurons = upperLayer.neurons

        let fIter = ForwardLoopIterator(upperNeurons, startingTarget.channel)
        let rIter = ReverseLoopIterator(upperNeurons, startingTarget.channel)

        var inputIDs = [Int]()

        for _ in 0..<connectingNeuron.upConnectors.count {
            let target = connectingNeuron.upConnectors.removeLast()
            connectingNeuron.weights.append(target.weight)  // save weight for the signaling step

            let iter: LoopIterator<[KNeuron]> = (target.channel >= 0) ? fIter : rIter

            guard let inputNeuron = skipDeadNeurons(iter) else { return inputIDs }
            inputIDs.append(inputNeuron.id.myID)
        }

        return inputIDs
    }

    func skipDeadNeurons(_ iter: LoopIterator<[KNeuron]>) -> KNeuron? {
        var boundsChecker = 0
        repeat {

            defer { boundsChecker += 1 }

            let targetNeuron = iter.compactNext()
            guard let connectible = targetNeuron.relay?.isOperational, connectible == true
                else { continue }

            return targetNeuron

        } while boundsChecker < iter.count

        return nil
    }
}
#endif
