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
struct LineChartLegendoidView_Previews: PreviewProvider {
    static var previews: some View {
        LineChartLegendoidView(legendSS: 0, legendoidSS: 0, switchSS: 0)
            .environmentObject(MockLineChartControls.controls)
    }
}
