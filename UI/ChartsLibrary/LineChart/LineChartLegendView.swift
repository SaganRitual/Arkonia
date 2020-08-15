import SwiftUI

struct LineChartLegendView: View {
    @EnvironmentObject var foodSuccessLineChartControls: LineChartControls

    let checkLeft: Bool
    let legendSS: Int
    let legendoidRange: Range<Int>

    init(legendSS: Int, legendoidRange: Range<Int>) {
        self.legendSS = legendSS
        self.legendoidRange = legendoidRange
        self.checkLeft = legendoidRange.lowerBound == 0
    }

    func getLegendText() -> some View {
        let legend = foodSuccessLineChartControls.akConfig.legends[legendSS]

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

    var body: some View { buildControls().font(foodSuccessLineChartControls.akConfig.legendFont) }
}

struct LineChartLegend_Previews: PreviewProvider {
    static var previews: some View {
        LineChartLegendView(legendSS: 0, legendoidRange: 0..<2)
            .environmentObject(MockLineChartControls.controls)
    }
}

