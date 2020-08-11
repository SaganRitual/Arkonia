import SwiftUI

struct LineChartHeaderView: View {
    @EnvironmentObject var lineChartControls: LineChartControls
    @EnvironmentObject var stats: PopulationStats

    var body: some View {
        VStack {
            Text(lineChartControls.akConfig.chartTitle)
                .font(ArkoniaLayout.labelFont)
                .foregroundColor(.white)

            HStack {
                LineChartLegendView(AKPoint(x: 0, y: 0))
                    .frame(maxWidth: .infinity)

                ZStack {
                    Text("\(stats.histogramsUpdateTrigger)").foregroundColor(.clear)
                    Spacer()
                }

                LineChartLegendView(AKPoint(x: 1, y: 0))
                    .frame(maxWidth: .infinity)
            }.font(ArkoniaLayout.meterFont)
        }
    }
}

struct LineChartHeaderView_Previews: PreviewProvider {
    static var previews: some View {
        LineChartHeaderView()
            .environmentObject(LineChartControls(
                LineChartBrowsingSuccess(),
                LineChartDataset()
            ))
    }
}
