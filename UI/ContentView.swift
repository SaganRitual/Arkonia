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

                    PopulationHudView()
                        .frame(width: ArkoniaLayout.AlmanacView.frameWidth)
                        .environmentObject(Census.shared.censusAgent.stats)

                    AgeHudView()
                        .frame(width: ArkoniaLayout.AlmanacView.frameWidth)
                        .environmentObject(Census.shared.censusAgent.stats)

                    OffspringHudView()
                        .frame(width: ArkoniaLayout.AlmanacView.frameWidth)
                        .environmentObject(Census.shared.censusAgent.stats)

                    FoodHitrateHudView()
                        .frame(width: ArkoniaLayout.AlmanacView.frameWidth)
                        .environmentObject(Census.shared.censusAgent.stats)
                        .environmentObject(MannaStats.stats)

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
