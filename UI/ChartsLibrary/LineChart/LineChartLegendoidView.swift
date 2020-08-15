import SwiftUI

struct LineChartLegendoidView: View {
    @EnvironmentObject var foodSuccessLineChartControls: LineChartControls

    let legendSS: Int
    let legendoidSS: Int
    let switchSS: Int

    var body: some View {
        Toggle(
            foodSuccessLineChartControls.akConfig.legendoids[legendoidSS].text,
            isOn: $foodSuccessLineChartControls.switches[switchSS]
        )
            .toggleStyle(ColoredSquareToggle(
                isOn: $foodSuccessLineChartControls.switches[switchSS],
                akConfig: foodSuccessLineChartControls.akConfig,
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
