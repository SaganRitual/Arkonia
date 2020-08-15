import SwiftUI

struct LineChartHeaderView: View {
    let lineChartControls: LineChartControls

    init(_ c: LineChartControls) { self.lineChartControls = c }

    var body: some View {
        VStack {
            Text(lineChartControls.akConfig.chartTitle)
                .font(lineChartControls.akConfig.titleFont)
                .foregroundColor(.white)

            HStack {
                LineChartLegendView(lineChartControls, legendSS: 0, legendoidRange: lineChartControls.akConfig.legends[0].legendoidRange)
                    .frame(maxWidth: .infinity)

                Spacer()

//                LineChartLegendView(legendSS: 1, legendoidRange: lineChartControls.akConfig.legends[1].legendoidRange)
//                    .frame(maxWidth: .infinity)
            }.font(lineChartControls.akConfig.legendFont)
        }
    }
}
//
//struct LineChartHeaderView_Previews: PreviewProvider {
//    static var previews: some View {
//        LineChartHeaderView()
//            .environmentObject(MockLineChartControls.controls)
//    }
//}
