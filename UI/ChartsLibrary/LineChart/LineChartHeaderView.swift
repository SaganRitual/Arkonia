import SwiftUI

struct LineChartHeaderView: View {
    @EnvironmentObject var foodSuccessLineChartControls: LineChartControls

    var body: some View {
        VStack {
            Text(foodSuccessLineChartControls.akConfig.chartTitle)
                .font(foodSuccessLineChartControls.akConfig.titleFont)
                .foregroundColor(.white)

            HStack {
                LineChartLegendView(legendSS: 0, legendoidRange: foodSuccessLineChartControls.akConfig.legends[0].legendoidRange)
                    .frame(maxWidth: .infinity)

                Spacer()

//                LineChartLegendView(legendSS: 1, legendoidRange: foodSuccessLineChartControls.akConfig.legends[1].legendoidRange)
//                    .frame(maxWidth: .infinity)
            }.font(foodSuccessLineChartControls.akConfig.legendFont)
        }
    }
}

struct LineChartHeaderView_Previews: PreviewProvider {
    static var previews: some View {
        LineChartHeaderView()
            .environmentObject(MockLineChartControls.controls)
    }
}
