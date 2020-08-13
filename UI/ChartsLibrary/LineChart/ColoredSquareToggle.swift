import SwiftUI

struct ColoredSquareToggle: ToggleStyle {
    @Binding var isOn: Bool

    let akConfig: LineChartConfiguration
    let legendoidSS: Int

    var color: Color { legendoid.color }
    var labelText: String { legendoid.text }

    var legendoid: LineChartLegendoidConfiguration {
        akConfig.legendoids[legendoidSS]
    }

    func toggleButton() { self.isOn.toggle() }

    func makeBody(configuration: Configuration) -> some View {
        return HStack {
            Button(action: self.toggleButton) {
                Rectangle()
                    .foregroundColor(isOn ? self.color : Color.gray)
                    .border(Color.black, width: 2)
                    .frame(width: 10, height: 10)
            }
            .buttonStyle(PlainButtonStyle())

            Text(labelText).foregroundColor(isOn ? Color.white : Color.gray)
        }
    }
}
