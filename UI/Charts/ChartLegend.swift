import SwiftUI

struct ChartLegend: View {
    @EnvironmentObject var dataSelectors: ChartLegendSelect

    let descriptors: [(Color, String)]
    let groupName: String

    var body: some View {
        VStack(alignment: .leading) {
            Text(groupName)
                .font(.system(size: 10))
                .padding(.top, 3)
                .padding(.bottom, -10)
                .padding(.leading, 6)

            HStack(alignment: .center) {
                VStack {
                    ForEach(0..<descriptors.count) { ss in
                        ChartLegendoid(
                            color: self.descriptors[ss].0,
                            label: self.descriptors[ss].1,
                            selectorSS: ss
                        )
                        .padding(.bottom, ss == 2 ? 0 : -7)
                        .padding(.top, ss == 0 ? 0 : -7)
                            .environmentObject(self.dataSelectors)
                    }
                }
            }
            .padding(.bottom, 5)
        }
    }
}

struct ChartLegend_Previews: PreviewProvider {
    static let dataSelectors = ChartLegendSelect(3)

    static var previews: some View {
        ChartLegend(
            descriptors: [
                (Color.green, "Avg"),
                (Color(NSColor.cyan), "Med"),
                (Color.blue, "Max")
            ],
            groupName: "Current"
        ).environmentObject(dataSelectors)
    }
}
