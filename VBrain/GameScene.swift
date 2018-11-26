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
  

import SpriteKit
import GameplayKit

class GameScene: SKScene {
    
    private var vBrain: VBrain!

    var frameCount = 0
    var curator: Curator!
    var curatorStatus = CuratorStatus.running
    var brain: NeuralNetProtocol!

    override func didMove(to view: SKView) {
    }
   
    // With deepest gratitude to Stack Overflow dude
    // https://stackoverflow.com/users/2346164/gilian-joosen
    // https://stackoverflow.com/a/26787701/1610473
    //
    func returnChar(_ theEvent: NSEvent) -> Character? {
        let s: String = theEvent.characters!
        for char in s{ return char }
        return nil
    }
    
    func getCurator() throws {
        guard self.curator == nil else { return }
        
        let testSubjects = TSTestGroup()
        let relay = TSRelay(testSubjects)
        let fitnessTester = FTLearnZoeName()
        let testSubjectFactory = TSZoeFactory(relay, fitnessTester: fitnessTester)
//        let fitnessTester = TestSubjectFitnessTester()
//        let testSubjectFactory = TestSubjectFactory(relay, fitnessTester: fitnessTester)
//        let starter = "L_T(b[-7.95671]v[63.14612])_T(b[21.17976]v[57.56750])_N_T(b[-27.70772]v[-33.91857])_B(b[-96.31301]v[56.66431])_B(b[-23.86541]v[-40.36922])_W(b[73.73098]v[93.70640])_T(b[33.68555]v[-33.49336])_B(b[53.78324]v[-74.27547])_T(b[32.97104]v[67.04623])_B(b[-69.51137]v[59.76457])_A(false)_A(true)_L_T(b[-3.09175]v[9.16331])_A(true)_W(b[49.66184]v[58.83627])_W(b[-47.01345]v[80.05414])_A(false)_W(b[-94.70618]v[72.05781])_W(b[36.83261]v[18.13791])_B(b[-81.96514]v[42.62069])_W(b[8.63549]v[-65.48458])_B(b[-6.47847]v[-44.69983])_W(b[-5.59150]v[-17.89173])_B(b[-93.70625]v[-36.70797])_A(false)_A(false)_W(b[72.06775]v[-84.24402])_A(true)_B(b[-87.57876]v[-88.20245])_B(b[-44.20781]v[-51.79160])_B(b[55.12465]v[96.16452])_T(b[-5.66240]v[37.42823])_A(false)_W(b[-48.35930]v[-73.07896])_T(b[-40.88650]v[33.60824])_B(b[-9.77748]v[51.65306])_B(b[91.48849]v[-40.64219])_W(b[20.01120]v[84.42383])_W(b[94.23150]v[67.87842])_B(b[-36.10656]v[-87.28404])_T(b[-75.45849]v[-3.52449])_A(false)_W(b[-28.05685]v[56.07188])_N_A(true)_B(b[22.25235]v[78.36592])_A(true)_T(b[16.28265]v[29.61630])_W(b[54.25272]v[-41.22765])_B(b[-92.12368]v[-92.18470])_A(true)_B(b[50.10045]v[-98.80657])_W(b[-99.74585]v[77.48291])_A(false)_T(b[68.33768]v[-9.18370])_W(b[-60.48378]v[-73.03770])_A(true)_A(false)_T(b[-8.44467]v[35.16485])_B(b[4.50162]v[-71.12255])_A(true)_W(b[-26.23836]v[-33.91092])_N_W(b[54.35479]v[-62.79462])_W(b[68.76664]v[-56.95574])_B(b[-54.33920]v[43.82285])_W(b[-89.43967]v[42.81052])_W(b[-9.75144]v[-38.34149])_W(b[-34.89751]v[3.75046])_T(b[-8.27439]v[-18.83358])_A(true)_A(true)_B(b[-37.11556]v[5.55978])_A(false)_N_A(false)_B(b[-39.51151]v[74.39984])_L_N_W(b[90.86461]v[-11.83246])_B(b[27.73657]v[49.64221])_B(b[37.73133]v[-11.24375])_N_W(b[81.46582]v[-59.80400])_N_A(false)_B(b[-45.30356]v[-14.28026])_N_B(b[36.94717]v[-38.99258])_A(true)_A(true)_W(b[98.57934]v[77.91175])_W(b[34.94405]v[-99.63570])_B(b[-52.59588]v[70.23378])_B(b[-31.58018]v[-52.39173])_N_A(true)_W(b[-20.80057]v[47.35920])_A(true)_B(b[-25.59893]v[90.33163])_W(b[-79.36011]v[-26.57053])_B(b[-17.10379]v[-11.95210])_W(b[-54.54015]v[-6.97102])_W(b[38.31548]v[-34.37245])_T(b[-59.70512]v[-11.95913])_A(false)_B(b[-37.08499]v[79.92048])_A(false)_A(false)_W(b[-16.31107]v[-55.11070])_T(b[-1.74550]v[-56.06134])_N_W(b[-50.62910]v[-45.64294])_N_t()_6()_f()_8()_f()_t()_N_N_A(false)_W(b[-84.62174]v[95.73330])_B(b[28.71035]v[-60.96150])_A(true)_T(b[-58.17411]v[87.39059])_W(b[25.96181]v[-23.11574])_B(b[32.57744]v[50.31316])_N_A(false)_A(false)_A(false)_T(b[-53.80203]v[-51.06673])_A(false)_T(b[6.28182]v[-87.91587])_W(b[8.11061]v[-36.86689])_T(b[-10.66383]v[-83.06327])_T(b[-55.20651]v[-16.83117])_A(true)_A(false)_B(b[-78.42863]v[94.39414])_T(b[-81.81689]v[-83.96307])_T(b[-50.20989]v[-86.86020])_W(b[17.94575]v[-19.18724])_A(true)_A(true)_A(true)_T(b[-78.86080]v[-50.22819])_A(false)_B(b[-90.46982]v[2.78686])_B(b[-3.77927]v[6.94487])_W(b[49.10845]v[27.77425])_A(true)_T(b[27.39363]v[36.36788])_W(b[-18.79015]v[-68.83548])_A(false)_A(true)_T(b[13.03966]v[-75.60036])_W(b[-97.72322]v[-7.01439])_W(b[-95.50985]v[-55.36910])_W(b[-28.24957]v[-49.33844])_A(true)_W(b[65.69699]v[26.86498])_T(b[25.45726]v[-17.52104])_A(false)_A(true)_W(b[63.61957]v[76.37222])_B(b[-53.78363]v[-32.87258])_W(b[47.32455]v[36.77160])_B(b[85.42303]v[-56.35778])_N_B(b[-80.35292]v[83.49948])_A(false)_T(b[71.72271]v[-9.76528])_B(b[87.52789]v[-37.09368])_A(true)_W(b[-73.62307]v[-86.19002])_A(true)_W(b[1.04262]v[21.17311])_A(true)_A(true)_N_B(b[-16.09625]v[20.45156])_W(b[-68.36037]v[-39.55342])_W(b[18.31652]v[60.69523])_A(true)_W(b[89.68122]v[-71.73131])_A(false)_T(b[48.11346]v[-8.39236])_W(b[-57.49925]v[-56.31905])_N_N_T(b[10.36177]v[-24.41148])_W(b[16.11877]v[-7.69018])_A(false)_W(b[-23.42625]v[46.87969])_T(b[-31.78751]v[50.26004])_W(b[5.84012]v[26.90077])_"
        self.curator = Curator(starter: nil, testSubjectFactory: testSubjectFactory)
    }
    
    var completionDisplayed = false
    override func update(_ currentTime: TimeInterval) {
        frameCount += 1
        
        do { try getCurator() }
        catch { return }
        
        guard let curator = self.curator else { return }
        
        guard self.curatorStatus == .running else {
            if !completionDisplayed {
                vBrain.displayBrain(self.brain, isFinalUpdate: true)
                completionDisplayed = true
            }
            return
        }
        
        self.curatorStatus = curator.track()

        switch self.curatorStatus {
        case .running: break
            
        case .finished: fallthrough
        case .chokedByDudliness:
            print("\nCompletion state: \(curatorStatus)")
        }

//        if frameCount < 60 { return }
//        print("?", terminator: "")
//        frameCount = 0

        guard let brainOk = try? curator.getMostInterestingTestSubject() else {
            return
        }
        
        self.brain = brainOk

        vBrain = VBrain(gameScene: self, brain: self.brain)
        vBrain.displayBrain(self.brain)
    }

}

