//
//  LineChartLineView.swift
//  Snapes
//
//  Created by Rob Bishop on 8/1/20.
//

import SwiftUI

struct LineChartLineView: View {
    @State var textUnitSize = ArkoniaLayout.labelTextSize

    func drawLine(_ viewWidth: CGFloat, _ viewHeight: CGFloat) -> Path {
        let points: [CGPoint] = (0..<11).map {
            CGSize(width: viewWidth, height: viewHeight).asPoint() *
            CGPoint(x: CGFloat($0), y: CGFloat.random(in: 0..<10)) / 10
        }

        var isFirst = true
        var prevPoint: CGPoint?
        var path = Path()

        // obv, there are lots of ways of doing this. let's
        // please refrain from yak shaving in the comments
        for point in points {
            if let prevPoint = prevPoint {
                let midPoint = (point + prevPoint) / 2

                if isFirst { path.addLine(to: midPoint) }
                else       { path.addQuadCurve(to: midPoint, control: prevPoint) }

                isFirst = false
            } else { path.move(to: point) }

            prevPoint = point
        }

        if let prevPoint = prevPoint { path.addLine(to: prevPoint) }

        return path
    }

    var body: some View {
        GeometryReader { gr in
            drawLine(gr.size.width, gr.size.height)
                .stroke(lineWidth: 1)
                .foregroundColor(.white)
                .offset(x: gr.size.width / 10 / 2)
        }
    }
}

struct LineChartLineView_Previews: PreviewProvider {
    static var previews: some View {
        LineChartLineView()
    }
}
