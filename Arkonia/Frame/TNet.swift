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

class TNet {
    var cMotorNeurons = ArkonCentralDark.selectionControls.cMotorNeurons
    var cSenseNeurons = ArkonCentralDark.selectionControls.cSenseNeurons
    var fishNumber: Int?
    var layers = [TLayer]()
    var underConstruction: TLayer?

    init() { }

    func beginNewLayer() -> TLayer {
        if underConstruction != nil {
            finalizeLayer()
            underConstruction = nil
        }

        underConstruction = TLayer()
        return underConstruction!
    }

    func finalizeLayer() {
        guard let u = underConstruction else { return }
        u.finalizeNeuron()
        layers.append(u)
        underConstruction = nil
    }

    func subjectSurvived(_ tNet: TNet?) -> TNet? {
        return layers.isEmpty ? nil : tNet
    }
}
