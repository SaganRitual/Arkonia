import SwiftUI

struct LineChartAxisLabelsView: View {
    @EnvironmentObject var lineChartControls: LineChartControls

    var body: some View {
        Rectangle()
            .foregroundColor(Color(white: 0.2))
            .overlay(
                GeometryReader { gr in
                    ZStack {
                        LineChartAxisTopMarkerView(whichAxis: CGPoint(x: 0, y: 1))
                            .offset(
                                x: -gr.size.width * 0.5 + gr.size.width * 0.05,
                                y: -gr.size.height * 0.5 + gr.size.height * 0.05
                            )

                        LineChartAxisView(whichAxis: CGPoint(x: 0, y: 1))
                            .offset(x: -gr.size.width * 0.5 + gr.size.width * 0.05)

                        LineChartAxisTopMarkerView(whichAxis: CGPoint(x: 1, y: 0))
                            .offset(
                                x: (gr.size.width * 0.5) - gr.size.width * 0.05,
                                y: (gr.size.height * 0.5) - gr.size.height * 0.05
                            )

                        LineChartAxisView(whichAxis: CGPoint(x: 1, y: 0))
                            .offset(y: (gr.size.height * 0.5) - gr.size.height * 0.05)

                        LineChartDataBackdrop()
                            .scaleEffect(1 / 1.1)
                            .offset(x: gr.size.width * 0.05, y: -gr.size.height * 0.05)
                    }
                    .font(lineChartControls.akConfig.axisLabelsFont)
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
