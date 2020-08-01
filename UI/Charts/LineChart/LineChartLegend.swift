import SwiftUI

struct LineChartLegendDescriptor {
    let title: String
    let legendoidDescriptors: [(Color, String)]
}

struct LineChartLegend: View {
    let descriptor: LineChartLegendDescriptor

    var body: some View {
        VStack(alignment: .center) {
            Text(descriptor.title)
                .font(.system(size: 12))

            HStack(alignment: .center) {
                VStack {
                    ForEach(0..<descriptor.legendoidDescriptors.count) { ss in
                        LineChartLegendoid(
                            color: self.descriptor.legendoidDescriptors[ss].0,
                            label: self.descriptor.legendoidDescriptors[ss].1
                        )
                    }
                }
            }
        }
    }
}

struct LineChartLegend_Previews: PreviewProvider {
    static let dataSelectors = ChartLegendSelect(3)

    static var previews: some View {
        LineChartLegend(
            descriptor: LineChartLegendDescriptor(
                title: "Current",
                legendoidDescriptors: [
                    (Color.green, "Avg"),
                    (Color(NSColor.cyan), "Med"),
                    (Color.blue, "Max")
                ]
            )

        )
    }
}
