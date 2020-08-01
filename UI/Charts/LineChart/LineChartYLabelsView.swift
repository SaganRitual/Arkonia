import SwiftUI

struct LineChartYLabelsView: View {
    @State var textUnitSize = ArkoniaLayout.labelTextSize

    var body: some View {
        GeometryReader { gr in
            VStack {
                ForEach(0..<10) { rowNumber in
                    Text(ArkoniaLayout.getLabelText(10 - rowNumber - 1))
                        .font(ArkoniaLayout.chartAxisLabelFont)
                        .offset(y: textUnitSize.height * 1.5)
                        .opacity(rowNumber < 9 ? 1 : 0)

                    Spacer()
                }
            }
        }
    }
}

struct LineChartYLabelsView_Previews: PreviewProvider {
    static var previews: some View {
        LineChartYLabelsView()
    }
}
