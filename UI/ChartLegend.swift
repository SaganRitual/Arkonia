import SwiftUI

struct ChartLegend: View {
    @EnvironmentObject var dataSelectors: ChartLegendSelect

    let descriptors: [(Color, String)]
    let groupName: String

    var body: some View {
        VStack(alignment: .leading) {
            Text(groupName)
                .font(.headline)
                .padding(.top, 5)
                .padding(.bottom, -10)
                .padding(.leading, 10)

            HStack {
                VStack {
                    ForEach(0..<descriptors.count) { ss in
                        ChartLegendoid(
                            color: descriptors[ss].0,
                            label: descriptors[ss].1,
                            selectorSS: ss
                        )
                        .padding(.bottom, ss == 2 ? 0 : -5)
                        .padding(.top, ss == 0 ? 0 : -5)
                        .environmentObject(dataSelectors)
                    }
                }
            }
            .padding(.leading, 10)
            .padding(.trailing, 10)
            .padding(.bottom, 5)
        }
    }
}

struct ChartLegend_Previews: PreviewProvider {
    static let dataSelectors = ChartLegendSelect(3)

    static var previews: some View {
        ChartLegend(
            descriptors: [
                (Color.green, "Average"),
                (Color(NSColor.cyan), "Median"),
                (Color.blue, "Maximum")
            ],
            groupName: "Current"
        ).environmentObject(dataSelectors)
    }
}
