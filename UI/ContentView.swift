import SpriteKit
import SwiftUI

struct ContentView: View {
    @EnvironmentObject var randomer: AKRandomNumberFakerator

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

                    NeuronsHudView()
                        .frame(width: ArkoniaLayout.AlmanacView.frameWidth)
                        .environmentObject(Census.shared.censusAgent.stats)

                    BrainyHudView()
                        .frame(width: ArkoniaLayout.AlmanacView.frameWidth)
                        .environmentObject(Census.shared.censusAgent.stats)

                    Spacer()
                }
                .frame(height: ArkoniaLayout.ContentView.hudHeight)

                GameView(scene: ArkoniaScene())
                    .sheet(isPresented: $randomer.isBusy) {
                        LlamaProgressView().environmentObject(self.randomer)
                    }
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
