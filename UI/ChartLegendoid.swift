import SwiftUI

// swiftlint:disable multiple_closures_with_trailing_closure
// "Multiple Closures with Trailing Closure Violation: Trailing closure syntax
// should not be used when passing more than one closure argument."

struct ChartLegendoid: View {
    @EnvironmentObject var dataSelector: ChartLegendSelect
    @State private var isActive = true

    let color: Color
    let label: String
    let selectorSS: Int

    var body: some View {
        HStack {
            Button(action: {
                isActive.toggle()
                dataSelector.toggle(selectorSS)
            }) {
                Rectangle()
                    .foregroundColor(isActive ? color : .gray)
                    .frame(width: 100, height: 10)
            }
            .buttonStyle(PlainButtonStyle())
            .padding(.leading, 7)

            Spacer()

            Text(label)
                .font(.subheadline)
                .padding(.trailing, 7)
                .foregroundColor(isActive ? .white : .gray)
        }
        .frame(width: 200, height: 20)
    }
}

struct ChartLegendoid_Previews: PreviewProvider {
    static var previews: some View {
        ChartLegendoid(
            color: .blue,
            label: "Preview",
            selectorSS: 0
        )
    }
}
