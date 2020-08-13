import SwiftUI

struct LineChartAxisLabelsView: View {
    @EnvironmentObject var lineChartControls: LineChartControls

    func getLabelText(_ value: Int) -> AnyView {
        switch lineChartControls.akConfig.yAxisMode {
        case .amLinear: return AnyView(HStack { Text("\(value)") } )
        case .amLog10:  return AnyView(HStack { Text("10").padding(.trailing, -5); Text("\(value)").baselineOffset(20).padding(.leading, -2) } )
        default: fatalError()
        }
    }

    var body: some View {
        ZStack {
            GeometryReader { gr in
                HStack(spacing: 0) {
                    Spacer()
                        .frame(width: gr.size.width * 0.1)
                        .overlay(
                            VStack {
                                ForEach(0..<4) {
                                    Text("\(8 - 2 * $0)")
                                        .font(lineChartControls.akConfig.axisLabelsFont)

                                    Spacer()
                                        .frame(height: 0.075 * gr.size.height + CGFloat($0) * 0.025 * gr.size.height)
                                }
                            }
                        )

                    VStack(spacing: 0) {
                        LineChartDataBackdrop()

                        Spacer()
                            .frame(
                                width: gr.size.width * 0.9,
                                height: gr.size.width * 0.1 // Note: my HEIGHT same as the other guy's WIDTH
                            )
                    }
                }
            }
        }
        .background(lineChartControls.akConfig.chartBackdropColor)
    }
}

struct LineChartAxisLabelsView_Previews: PreviewProvider {
    static var previews: some View {
        LineChartAxisLabelsView()
            .frame(width: 300, height: 200)
            .environmentObject(MockLineChartControls.controls)
    }
}
