import SwiftUI

struct LineChartHeaderView: View {
    @EnvironmentObject var lineChartControls: LineChartControls



    var body: some View {
        VStack {
            Text(lineChartControls.akConfig.chartTitle)
                .font(lineChartControls.akConfig.titleFont)
                .foregroundColor(.white)

            HStack {
                LineChartLegendView(legendSS: 0, legendoidRange: lineChartControls.akConfig.legends[0].legendoidRange)
                    .frame(maxWidth: .infinity)

                Spacer()

                LineChartLegendView(legendSS: 1, legendoidRange: lineChartControls.akConfig.legends[1].legendoidRange)
                    .frame(maxWidth: .infinity)
            }.font(lineChartControls.akConfig.legendFont)
        }
    }
}

class LineChartHeaderView_Previews_PreviewsLineData: LineChartLineDataProtocol {
    func getPlotPoints() -> [CGPoint] {
        (Int(0)..<Int(10)).map { CGPoint(x: Double($0), y: Double.random(in: 0..<10)) }
    }
}

struct LineChartHeaderView_Previews: PreviewProvider {
    static var dataset = LineChartDataset(count: 6, constructor: { LineChartHeaderView_Previews_PreviewsLineData() })

    static var lineChartControls = LineChartControls(
        LineChartBrowsingSuccess(), dataset
    )

    static var previews: some View {
        LineChartHeaderView()
            .environmentObject(
                LineChartControls(
                    LineChartBrowsingSuccess(),
                    LineChartDataset(
                        count: 2, constructor: { LineChartHeaderView_Previews_PreviewsLineData() }
                    )
                )
            )
    }
}
