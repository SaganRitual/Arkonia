//
//  SundialView.swift
//  Fuck
//
//  Created by Rob Bishop on 7/29/20.
//

import SwiftUI

extension Double {
    static let piOverTwo = Double.pi / 2
    static let threePiOverTwo = 3 * Double.pi / 2
}

struct SundialView: View {
    @EnvironmentObject var seasonalFactors: SeasonalFactors

    var sundialLayout: SundialLayout!

    init(_ formula: SeasonalFactors.Formula) {
        self.sundialLayout = SundialLayout()
    }

    var body: some View {
        VStack {
            ZStack {
                Rectangle()
                    .frame(
                        width: ArkoniaLayout.SeasonFactorView.bgFrameWidth,
                        height: ArkoniaLayout.SeasonFactorView.bgFrameHeight
                    )
                    .foregroundColor(Color(NSColor.darkGray))

                Rectangle()
                    .frame(
                        width: ArkoniaLayout.SeasonFactorView.annualTrackFrameWidth,
                        height: ArkoniaLayout.SeasonFactorView.annualTrackFrameHeight
                    )
                    .cornerRadius(5)
                    .foregroundColor(Color(NSColor(calibratedWhite: 0.1, alpha: 1)))

                ZStack {
                    // Time of year
                    Image("sundial")
                        .frame(
                            width: sundialLayout.annualMarkerFrameSize.width,
                            height: sundialLayout.annualMarkerFrameSize.height
                        )
                        .blendMode(.hardLight)
                        .colorMultiply(.yellow)
                        .opacity(0.75)
                        .scaleEffect(
                            CGSize(
                                width: 1,
                                height:
                                    (sundialLayout.seasonIsAscending ? 1 : -1) *
                                    sundialLayout.annualMarkerFrameHeightScale
                            )
                        )
                        .offset(y: -CGFloat(sundialLayout.annualMarkerPosition))
                        .animation(.linear)

                    // Temperature marker
                    Rectangle()
                        .frame(width: sundialLayout.annualTrackFrameSize.width / 0.25, height: 5)
                        .foregroundColor(Color.black)
                        .offset(y: -CGFloat(sundialLayout.diurnalMarkerPosition))
                        .animation(.linear)

                    // Time of day
                    Image("sundial")
                        .blendMode(.normal)
                        .colorMultiply(.gray)
                        .colorMultiply(.green)
                        .scaleEffect(
                            CGSize(
                                width: 0.25,
                                height:
                                    (sundialLayout.sunIsAscending ? 1 : -1) *
                                    sundialLayout.diurnalMarkerFrameHeightScale
                            )
                        )
                        .offset(y: -CGFloat(sundialLayout.diurnalMarkerPosition))
                        .animation(.linear)
                }
            }
        }
    }
}

struct SundialView_Previews: PreviewProvider {
    static var previews: some View {
        SundialView(.simpleSineAddition)
    }
}
