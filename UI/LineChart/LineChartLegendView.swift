import SwiftUI

struct LineChartLegendView: View {
    @EnvironmentObject var lineChartControls: LineChartControls

    let checkLeft: Bool
    let legendSS: Int
    let legendoidRange: Range<Int>

    init(legendSS: Int, legendoidRange: Range<Int>) {
        self.legendSS = legendSS
        self.legendoidRange = legendoidRange
        self.checkLeft = legendoidRange.lowerBound == 0
    }

    func getLegendText() -> some View {
        let legend = lineChartControls.akConfig.legends[legendSS]

        if legend.titleEdge == (checkLeft ? .leading : .trailing) {
            return AnyView(Text(legend.legendTitle)
                    .padding(checkLeft ? .leading : .trailing, 15)
            )
        } else {
            return AnyView(EmptyView())
        }
    }

    func buildControls() -> some View {
        HStack(alignment: .center) {
            if checkLeft { getLegendText() }

            VStack(alignment: .center) {
                ForEach(legendoidRange) { ss in
                    LineChartLegendoidView(
                        legendSS: legendSS, legendoidSS: ss,
                        switchSS: legendoidRange.lowerBound + ss
                    )
                }.padding([.leading, .trailing], 5)
            }

            if !checkLeft { getLegendText() }
        }
    }

    var body: some View { buildControls().font(lineChartControls.akConfig.legendFont) }
}

class LineChartLegend_Previews_PreviewsLineData: LineChartLineDataProtocol {
    func getPlotPoints() -> [CGPoint] {
        (Int(0)..<Int(10)).map { CGPoint(x: Double($0), y: Double.random(in: 0..<10)) }
    }
}

struct LineChartLegend_Previews: PreviewProvider {
    static var dataset = LineChartDataset(count: 6, constructor: { LineChartLegend_Previews_PreviewsLineData() })

    static var lineChartControls = LineChartControls(
        LineChartBrowsingSuccess(), dataset
    )

    static var previews: some View {
        LineChartLegendView(legendSS: 0, legendoidRange: 0..<2)
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

