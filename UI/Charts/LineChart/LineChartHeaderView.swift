//
//  LineChartHeaderView.swift
//  Shapes
//
//  Created by Rob Bishop on 7/30/20.
//

import SwiftUI

struct LineChartHeaderView: View {
    let title: String
    let legend1Descriptor: LineChartLegendDescriptor
    let legend2Descriptor: LineChartLegendDescriptor

    var body: some View {
        HStack {
            LineChartLegend(descriptor: legend1Descriptor)
            Text(title).frame(minWidth: 200).font(.headline)
            LineChartLegend(descriptor: legend2Descriptor)
        }.padding(5).border(Color.black, width: 1)
    }
}

struct LineChartHeaderView_Previews: PreviewProvider {
    static var previews: some View {
        LineChartHeaderView(
            title: "Neuron Counts",
            legend1Descriptor: LineChartLegendDescriptor(
                title: "Current",
                legendoidDescriptors: [
                    (Color.yellow, "Min"),
                    (Color.blue, "Max"),
                    (Color.green, "Med")
                ]
            ),
            legend2Descriptor: LineChartLegendDescriptor(
                title: "All-time",
                legendoidDescriptors: [
                    (Color.orange, "Min"),
                    (Color.purple, "Max"),
                    (Color(NSColor.cyan), "Med")
                ]
            )
        )
    }
}
