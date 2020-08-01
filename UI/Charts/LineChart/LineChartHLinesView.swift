//
//  LineChartHLinesView.swift
//  Snapes
//
//  Created by Rob Bishop on 8/1/20.
//

import SwiftUI

struct LineChartHLinesView: View {
    @State var textUnitSize = ArkoniaLayout.labelTextSize

    var body: some View {
        GeometryReader { gr in
            VStack {
                ForEach(0..<10) { rowNumber in
                    Rectangle().frame(height: 1)   // 1px high
                    Spacer()
                }
            }
        }
    }
}

struct LineChartHLinesView_Previews: PreviewProvider {
    static var previews: some View {
        LineChartHLinesView()
    }
}
