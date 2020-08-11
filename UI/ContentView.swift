import SpriteKit
import SwiftUI

struct ContentView: View {
    @EnvironmentObject var randomer: AKRandomNumberFakerator

    var body: some View {
        HStack {
            Spacer()

            SundialView(.simpleSineAddition)
                .frame(width: ArkoniaLayout.SeasonFactorView.frameWidth)
                .environmentObject(Clock.shared.seasonalFactors)

            VStack {
                HudView()
                    .frame(height: ArkoniaLayout.ContentView.hudHeight)
                    .environmentObject(Census.shared.censusAgent.stats)

                GameView(scene: ArkoniaScene())
//                    .sheet(isPresented: $randomer.isBusy) {
//                        LlamaProgressView().environmentObject(self.randomer)
//                    }
            }

            VStack {
                ForEach(0..<5) { _ in
                    LineChartTheChartView()
                        .environmentObject(
                            LineChartControls(
                                LineChartBrowsingSuccess(),
                                Census.shared.censusAgent.stats.foodSuccessHistograms
                            )
                        )
                        .frame(
                            width: ArkoniaLayout.LineChartView.frameWidth,
                            height: ArkoniaLayout.LineChartView.frameHeight
                        )
                        .padding([.trailing, .bottom, .leading])
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
