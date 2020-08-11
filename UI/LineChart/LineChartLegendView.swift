import SwiftUI

struct LineChartLegendView: View {
    @EnvironmentObject var lineChartControls: LineChartControls

    let checkLeft: Bool
    let legendCoordinates: AKPoint

    var leadingLegendIndexes: Range<Int> { (lineChartControls.akConfig as? LineChartBrowsingSuccess)!.leadingLegendIndexes }
    var trailingLegendIndexes: Range<Int> { (lineChartControls.akConfig as? LineChartBrowsingSuccess)!.trailingLegendIndexes }

    init(_ legendCoordinates: AKPoint) {
        self.legendCoordinates = legendCoordinates
        self.checkLeft = legendCoordinates.x == 0
    }

    func getLegendText() -> some View {
        let legend = lineChartControls.akConfig.getLegend(at: legendCoordinates)!
        if legend.titleEdge == (checkLeft ? .leading : .trailing) {
            return AnyView(Text(legend.legendTitle)
                    .padding(checkLeft ? .leading : .trailing, 15)
            )
        } else {
            return AnyView(EmptyView())
        }
    }

    func buildLeftLegendIf() -> some View {
        if leadingLegendIndexes.isEmpty { return AnyView(EmptyView()) }

        let legend = lineChartControls.akConfig.getLegend(at: legendCoordinates)!
        if legend.titleEdge != .leading { return AnyView(EmptyView()) }

        return AnyView(getLegendText())
    }

    func buildRightLegendIf() -> some View {
        if trailingLegendIndexes.isEmpty { return AnyView(EmptyView()) }

        let legend = lineChartControls.akConfig.getLegend(at: legendCoordinates)!
        if legend.titleEdge != .trailing { return AnyView(EmptyView()) }

        return AnyView(getLegendText())
    }

    func getliveLegendoidCoordinates(_ ss_: Int) -> AKPoint {
        let ss = checkLeft ? ss_ : ss_ - trailingLegendIndexes.lowerBound
        return lineChartControls.liveLegendoidPositions[ss]
    }

    func buildControls() -> some View {
        return AnyView(
            HStack(alignment: .center) {
                if checkLeft { buildLeftLegendIf() }

                VStack(alignment: .center) {
                    ForEach(checkLeft ? leadingLegendIndexes : trailingLegendIndexes) { ss in
                        LineChartLegendoidView(
                            at: getliveLegendoidCoordinates(
                                checkLeft ? ss : ss + leadingLegendIndexes.upperBound
                            )
                        )
                    }.padding([.leading, .trailing], 5)
                }

                if !checkLeft { buildRightLegendIf() }
            }
        )
    }

    var body: some View { buildControls().font(ArkoniaLayout.meterFont) }
}

struct LineChartLegend_Previews: PreviewProvider {
    static var previews: some View {
        LineChartLegendView(AKPoint(x: 0, y: 0)).environmentObject(
            LineChartControls(LineChartBrowsingSuccess(), LineChartDataset())
        )
    }
}
