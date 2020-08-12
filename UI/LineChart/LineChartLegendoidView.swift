import SwiftUI

struct LineChartLegendoidView: View {
    @EnvironmentObject var lineChartControls: LineChartControls

    let legendSS: Int
    let legendoidSS: Int
    let switchSS: Int

    var body: some View {
        Toggle(
            lineChartControls.akConfig.legendoids[legendoidSS].text,
            isOn: $lineChartControls.switches[switchSS]
        )
            .toggleStyle(ColoredSquareToggle(
                isOn: $lineChartControls.switches[switchSS],
                akConfig: lineChartControls.akConfig,
                legendoidSS: legendoidSS
            ))
    }
}

class LineChartLegendoidView_Previews_PreviewsLineData: LineChartLineDataProtocol {
    func getPlotPoints() -> [CGPoint] {
        (Int(0)..<Int(10)).map { CGPoint(x: Double($0), y: Double.random(in: 0..<10)) }
    }
}

struct LineChartLegendoidView_Previews: PreviewProvider {
    static var dataset = LineChartDataset(count: 6, constructor: { LineChartLegend_Previews_PreviewsLineData() })

    static var lineChartControls = LineChartControls(
        LineChartBrowsingSuccess(), dataset
    )

    static var previews: some View {
        LineChartLegendoidView(legendSS: 0, legendoidSS: 0, switchSS: 0)
            .environmentObject(
                LineChartControls(
                    LineChartBrowsingSuccess(),
                    LineChartDataset(
                        count: 2, constructor: { LineChartLegend_Previews_PreviewsLineData() }
                    )
                )
            )
    }
}
