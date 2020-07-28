import SwiftUI

// swiftlint:disable multiple_closures_with_trailing_closure
// "Multiple Closures with Trailing Closure Violation: Trailing closure syntax
// should not be used when passing more than one closure argument."
struct ButtonsView: View {
    @EnvironmentObject var lineChartCore: LineChartCore
    @State private var showingAgeLineChart = false
    @State private var showingFoodHitRateLineChart = false
    @State private var showingNeuronsLineChart = false
    @State private var showingOffspringLineChart = false
    @State private var showingPopulationLineChart = false

    let buttonLabels = [
        "Age", "Food hit rate", "Neurons", "Offspring", "Population", "Krakens"
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
        ZStack(alignment: .leading) {
            Rectangle()
                .foregroundColor(Color.white.opacity(0.01))

            VStack {
                Text("Line charts")
                    .foregroundColor(.white)
                    .font(.headline)
                    .underline()

                HStack {
                    Button(action: { self.showChart(0) }) {
                        Text(buttonLabels[0]).frame(minWidth: ArkoniaLayout.ButtonsView.buttonLabelsFrameMinWidth)
                    }
                    .foregroundColor(.black)

                    Spacer()

                    Button(action: { self.showChart(1) }) {
                        Text(buttonLabels[1]).frame(minWidth: ArkoniaLayout.ButtonsView.buttonLabelsFrameMinWidth)
                    }
                    .foregroundColor(.black)
                }

                HStack {
                    Button(action: { self.showChart(2) }) {
                        Text(buttonLabels[2]).frame(minWidth: ArkoniaLayout.ButtonsView.buttonLabelsFrameMinWidth)
                    }
                    .foregroundColor(.black)

                    Spacer()

                    Button(action: { self.showChart(3) }) {
                        Text(buttonLabels[3]).frame(minWidth: ArkoniaLayout.ButtonsView.buttonLabelsFrameMinWidth)
                    }
                    .foregroundColor(.black)
                }

                HStack {
                    Button(action: { self.showChart(4) }) {
                        Text(buttonLabels[4]).frame(minWidth: ArkoniaLayout.ButtonsView.buttonLabelsFrameMinWidth)
                    }
                    .foregroundColor(.black)

                    Spacer()

                    Button(action: { self.showChart(5) }) {
                        Text(buttonLabels[5]).frame(minWidth: ArkoniaLayout.ButtonsView.buttonLabelsFrameMinWidth)
                    }
                    .foregroundColor(.black)
                }
            }.padding(.leading).frame(width: 200)
        }
    }
}

struct ButtonsView_Previews: PreviewProvider {
    static var previews: some View {
        ButtonsView()
    }
}
