import SwiftUI

struct LineChartLegendView: View {

    let checkLeft: Bool
    let legendSS: Int
    let legendoidRange: Range<Int>
    let lineChartControls: LineChartControls

    init(_ c: LineChartControls, legendSS: Int, legendoidRange: Range<Int>) {
        self.lineChartControls = c
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

