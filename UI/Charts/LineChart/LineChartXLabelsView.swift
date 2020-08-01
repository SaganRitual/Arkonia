import SwiftUI

struct LineChartXLabelsView: View {
    @State var textUnitSize = ArkoniaLayout.labelTextSize

    var body: some View {
        GeometryReader { gr in
            HStack {
                ForEach(0..<10) { columnNumber in
                    Text(ArkoniaLayout.getLabelText(columnNumber))
                        .font(ArkoniaLayout.chartAxisLabelFont)
                        .offset(x: -textUnitSize.width * 0.75)
                        .opacity(columnNumber > 0 ? 1 : 0)

                    Spacer()
                }
            }
        }
    }
}

struct LineChartXLabelsView_Previews: PreviewProvider {
    static var previews: some View {
        LineChartXLabelsView()
    }
}
