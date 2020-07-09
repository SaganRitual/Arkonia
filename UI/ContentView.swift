import SpriteKit
import SwiftUI

struct ContentView: View {
    @EnvironmentObject var lineChartData: LineChartData
    @State private var showingAgeLineChart = false
    @State private var showingFoodHitRateLineChart = false
    @State private var showingNeuronsLineChart = false
    @State private var showingOffspringLineChart = false
    @State private var showingPopulationLineChart = false

    let buttonLabels = [
        "Age", "Food hit rate", "Neurons", "Offspring", "Population"
    ]

    private func showChart(_ chartSS: Int) {
        switch chartSS {
        case 0: NSApp.sendAction(#selector(AppDelegate.openPreferencesWindow), to: nil, from:nil)
        case 1: showingFoodHitRateLineChart.toggle()
        case 2: showingNeuronsLineChart.toggle()
        case 3: showingOffspringLineChart.toggle()
        case 4: showingPopulationLineChart.toggle()
        default: fatalError()
        }
    }

    var body: some View {
        VStack {
            ZStack {
                Rectangle()
                    .foregroundColor(Color.gray)
                    .frame(maxWidth: .infinity)

                ZStack(alignment: .leading) {
                    Rectangle()
                        .foregroundColor(Color(NSColor.darkGray))

                    VStack {
                        Text("Line charts")
                            .foregroundColor(.black)
                            .font(.headline)
                            .underline()

                        ForEach(0..<buttonLabels.count) { labelSS in
                            HStack {
                                Button(action: { self.showChart(labelSS) } ) {
                                    Text(buttonLabels[labelSS]).frame(minWidth: 75)
                                }
                                .foregroundColor(.black)
                            }
                        }
                    }.padding(.leading)
                }
            }.frame(height: 200)

            GameView(scene: GameScene())
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
