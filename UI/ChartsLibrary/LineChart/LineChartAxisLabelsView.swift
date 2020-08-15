import SwiftUI

struct LineChartAxisLabelsView: View {
    @EnvironmentObject var foodSuccessLineChartControls: LineChartControls

    func halfNhalf(_ big: CGFloat, _ small: CGFloat) -> CGFloat {
        big * 0.5 + small * 0.05
    }

    var body: some View {
        Rectangle()
            .foregroundColor(Color(white: 0.2))
            .overlay(
                GeometryReader { gr in
                    ZStack {
                        LineChartAxisTopMarkerView(whichAxis: CGPoint(x: 0, y: 1))
                            .offset(
                                x: halfNhalf(-gr.size.width, gr.size.width),
                                y: halfNhalf(-gr.size.height, gr.size.height)
                            )

                        LineChartAxisView(whichAxis: CGPoint(x: 0, y: 1))
                            .offset(x: halfNhalf(-gr.size.width, gr.size.width))

                        LineChartAxisTopMarkerView(whichAxis: CGPoint(x: 1, y: 0))
                            .offset(
                                x: halfNhalf(gr.size.width, -gr.size.width),
                                y: halfNhalf(gr.size.height, -gr.size.height)
                            )

                        LineChartAxisView(whichAxis: CGPoint(x: 1, y: 0))
                            .offset(y: halfNhalf(gr.size.height, -gr.size.height))

                        LineChartDataBackdrop()
                            .scaleEffect(1 / 1.1)
                            .offset(x: gr.size.width * 0.05, y: -gr.size.height * 0.05)
                    }
                    .environmentObject(foodSuccessLineChartControls.dataset!)
                    .font(foodSuccessLineChartControls.akConfig.axisLabelsFont)
                }
            )
   }
}

struct LineChartAxisLabelsView_Previews: PreviewProvider {
    static var previews: some View {
        LineChartAxisLabelsView()
            .environmentObject(MockLineChartControls.controls)
    }
}
