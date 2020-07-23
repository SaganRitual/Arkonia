import SpriteKit
import SwiftUI

struct ContentView: View {
    var body: some View {
        HStack {
            Spacer()

            SeasonFactorView()
                .frame(width: ArkoniaLayout.SeasonFactorView.frameWidth)
                .environmentObject(Clock.shared.seasonalFactors)

            VStack {
                HStack {
                    Spacer()

                    AlmanacHudView().environmentObject(Clock.shared.seasonalFactors)
                        .frame(width: ArkoniaLayout.AlmanacView.frameWidth)

                    Spacer()

                    PopulationHudView()
                        .frame(width: ArkoniaLayout.AlmanacView.frameWidth)
                        .environmentObject(Census.shared.censusAgent.stats)
                        .environmentObject(MannaStats.stats)

                    Spacer()

                    AgeHudView()
                        .frame(width: ArkoniaLayout.AlmanacView.frameWidth)
                        .environmentObject(Census.shared.censusAgent.stats)

                    Spacer()

                    FoodHitrateHudView()
                        .frame(width: ArkoniaLayout.AlmanacView.frameWidth)
                        .environmentObject(Census.shared.censusAgent.stats)

                    Spacer()
                }
                .frame(height: ArkoniaLayout.ContentView.hudHeight)

                GameView(scene: ArkoniaScene())
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
