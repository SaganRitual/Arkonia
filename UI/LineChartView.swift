import SpriteKit
import SwiftUI
import Charts
import Shapes

class ChartLegendSelect: ObservableObject {
    @Published var dataSelectors = [Bool]()

    init(_ cSelectors: Int) {
        (0..<cSelectors).forEach { _ in dataSelectors.append(true) }
    }

    func toggle(_ selectorSS: Int) {
        dataSelectors[selectorSS] = !dataSelectors[selectorSS]
    }
}

struct LineChartView: View {
    @EnvironmentObject var lineChartData: LineChartData

    let dataSelectorsLeft = ChartLegendSelect(3)
    let dataSelectorsRight = ChartLegendSelect(3)

    var body: some View {
        VStack {
            HStack {
                VStack(alignment: .leading) {
                    ChartLegend(
                        descriptors: [
                            (Color.green, "Average"),
                            (Color(NSColor.cyan), "Median"),
                            (Color.blue, "Maximum")
                        ],
                        groupName: "Current"
                    ).environmentObject(dataSelectorsLeft)
                }

                Spacer()
                Text("Age").font(.title).offset(y: 10)
                Spacer()

                VStack(alignment: .leading) {
                    ChartLegend(
                        descriptors: [
                            (Color.red, "Average"),
                            (Color.yellow, "Median"),
                            (Color.purple, "Maximum")
                        ],
                        groupName: "All-time"
                    ).environmentObject(dataSelectorsRight)
                }
            }.padding(.top, 10)

            HStack {
                VStack {
                    AxisLabels(.vertical, data: 0..<10, id: \.self) {
                        Text("\((10 - 1) - $0)")
                            .fontWeight(.bold)
                            .font(Font.system(size: 8))
                            .foregroundColor(.secondary)
                    }
                    .frame(width: 20)

                    Rectangle().foregroundColor(.clear).frame(width: 20, height: 0)
                }

                VStack {
                    Rectangle().foregroundColor(.clear).frame(width: 20, height: 10)

                    ZStack {
                        Chart(data: lineChartData.theData[0])
                            .chartStyle(
                                LineChartStyle(.quadCurve, lineColor: dataSelectorsLeft.dataSelectors[0] ? .green : .clear, lineWidth: 2)
                            )
                            .padding()

                        Chart(data: lineChartData.theData[1])
                            .chartStyle(
                                LineChartStyle(.quadCurve, lineColor: dataSelectorsLeft.dataSelectors[1] ? Color(NSColor.cyan) : .clear, lineWidth: 2)
                            )
                            .padding()

                        Chart(data: lineChartData.theData[2])
                            .chartStyle(
                                LineChartStyle(.quadCurve, lineColor: dataSelectorsLeft.dataSelectors[2] ? .blue : .clear, lineWidth: 2)
                            )
                            .padding()

                        Chart(data: lineChartData.theData[3])
                            .chartStyle(
                                LineChartStyle(.quadCurve, lineColor: dataSelectorsRight.dataSelectors[0] ? .red : .clear, lineWidth: 2)
                            )
                            .padding()

                        Chart(data: lineChartData.theData[4])
                            .chartStyle(
                                LineChartStyle(.quadCurve, lineColor: dataSelectorsRight.dataSelectors[1] ? .yellow : .clear, lineWidth: 2)
                            )
                            .padding()

                        Chart(data: lineChartData.theData[5])
                            .chartStyle(
                                LineChartStyle(.quadCurve, lineColor: dataSelectorsRight.dataSelectors[2] ? .purple : .clear, lineWidth: 2)
                            )
                            .padding()
                            .background(
                                GridPattern(
                                    horizontalLines: 10, verticalLines: 0
                                )
                                .stroke(
                                    Color.white.opacity(0.1),
                                    style: .init(lineWidth: 2, lineCap: .round)
                                )
                            )
                    }

                    Rectangle().foregroundColor(.clear).frame(width: 20, height: 20)
                }
                .layoutPriority(1)
            }
        }
    }

}

struct LineChartView_Previews: PreviewProvider {
    static var previews: some View {
        LineChartView()
    }
}
