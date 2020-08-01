//
//  LineChartVLinesView.swift
//  Snapes
//
//  Created by Rob Bishop on 8/1/20.
//

import SwiftUI

struct LineChartVLinesView: View {
    @State var textUnitSize = ArkoniaLayout.labelTextSize

    var body: some View {
        GeometryReader { gr in
            HStack {
                ForEach(0..<10) { columnNumber in
                    Rectangle().frame(width: 1)   // 1px wide
                    Spacer()
                }
            }
        }
    }
}

struct LineChartVLinesView_Previews: PreviewProvider {
    static var previews: some View {
        LineChartVLinesView()
    }
}
