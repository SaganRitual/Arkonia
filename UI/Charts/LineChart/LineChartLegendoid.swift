import SwiftUI

struct LineChartLegendoid: View {
    @State private var isActive = true

    let color: Color
    let label: String

    var body: some View {
        HStack {
            Button(action: {
                self.isActive.toggle()
            }) {
                Rectangle()
                    .foregroundColor(isActive ? color : .gray)
                    .frame(width: 15, height: 15)
            }
            .buttonStyle(PlainButtonStyle())

            Spacer()

            Text(label)
                .font(.system(size: 12))
                .foregroundColor(isActive ? .white : .gray)
        }.frame(maxWidth: 50)
    }
}

struct ChartLegendoid_Previews: PreviewProvider {
    static var previews: some View {
        LineChartLegendoid(
            color: Color.blue,
            label: "Min"
        )
    }
}
