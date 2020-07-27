import Charts
import SwiftUI

struct LlamaProgressView: View {
    @EnvironmentObject var randomer: AKRandomNumberFakerator

    var body: some View {
        ZStack {
            Rectangle()
                .frame(width: 300)
                .foregroundColor(Color.white.opacity(0.01))

            VStack {
                #if DEBUG
                Text(randomer.isLloading ? "Lloading Llittle Llamas" : "Normallizing")
                    .frame(height: 30)
                #else
                Text(randomer.isLloading ? "Lloading Llamas" : "Normallizing")
                    .frame(height: 30)
                #endif

                Chart(data: randomer.histogramPublishedArray)
                    .chartStyle(
                        ColumnChartStyle(column: Capsule().foregroundColor(.green), spacing: 2)
                    )
                    .frame(width: 100, height: 200)
                    .padding(.top, -100)

                ZStack(alignment: .leading) {
                    Rectangle()
                        .frame(height: 30)
                        .foregroundColor(Color.white.opacity(0.5))
                        .border(Color.black)
                        .padding(.top, 3)

                    Rectangle()
                        .frame(width: CGFloat(randomer.llamaFullness) * 250, height: 30 - 2)
                        .foregroundColor(Color.black.opacity(0.5))
                        .offset(y: 1.5)
                }
            }.frame(width: 250, height: 250)
        }
    }
}

struct LlamaProgressView_Previews: PreviewProvider {
    static var previews: some View {
        LlamaProgressView().environmentObject(AKRandomNumberFakerator())
    }
}
