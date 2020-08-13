import SwiftUI

struct NineChartAxisLabelView: View {
    @EnvironmentObject var lineChartControls: LineChartControls

    func getLabelText(_ value: Int) -> AnyView {
        switch lineChartControls.akConfig.yAxisMode {
        case .amLinear:
            return AnyView(HStack { Text("\(value)") } )

        case .amLog10:
            return AnyView(
                HStack {
                    Text("10").padding(.trailing, -5)
                    Text("\(value)").baselineOffset(20).padding(.leading, -2)
                }
            )

        default: fatalError()
        }
    }

    var body: some View {
        HStack {
            ForEach(0..<8) { ss in getLabelText(ss + 1).padding([.leading, .bottom]) }
        }
        .font(LineChartBrowsingSuccess.chartAxisLabelFont)
    }
}

struct LineChartAxisLabelView_Previews: PreviewProvider {
    static var previews: some View {
        NineChartAxisLabelView()
            .environmentObject(MockLineChartControls.controls)
    }
}
