import SwiftUI

struct LineChartLegendoidView: View {
    @EnvironmentObject var lineChartControls: LineChartControls

    let legendCoordinates: AKPoint

    var switchSS: Int { lineChartControls.getLegendoidSS(at: legendCoordinates) }

    init(at legendCoordinates: AKPoint) {
        self.legendCoordinates = legendCoordinates
    }

    var body: some View {
        Toggle(
            lineChartControls.akConfig.getLegendoid(at: legendCoordinates)!.text,
            isOn: $lineChartControls.switches[switchSS]
        )
            .toggleStyle(ColoredSquareToggle(
                isOn: $lineChartControls.switches[switchSS],
                akConfig: lineChartControls.akConfig,
                legendCoordinates: legendCoordinates
            ))
    }
}

struct LineChartLegendoidView_Previews: PreviewProvider {
    static var previews: some View {
        LineChartLegendoidView(at: AKPoint(x: 0, y: 0)).environmentObject(
            LineChartControls(LineChartBrowsingSuccess(), LineChartDataset())
        )
    }
}
