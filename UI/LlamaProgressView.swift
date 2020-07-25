import SwiftUI

struct LlamaProgressView: View {
    @EnvironmentObject var randomer: AKRandomNumberFakerator

    var body: some View {
        ZStack {
            Rectangle()
                .frame(width: 300, height: 100)
                .foregroundColor(Color.white.opacity(0.01))

            VStack {
                #if DEBUG
                Text(randomer.isLloading ? "Lloading Llittle Llamas" : "Normallizing")
                #else
                Text(randomer.isLloading ? "Lloading Llamas" : "Normallizing")
                #endif

                ZStack(alignment: .leading) {
                    Rectangle()
                        .frame(width: 250, height: 30)
                        .foregroundColor(Color.white.opacity(0.5))
                        .border(Color.black)
                        .padding(.top, 3)

                    Rectangle()
                        .frame(width: CGFloat(randomer.llamaFullness) * 250, height: 30 - 2)
                        .foregroundColor(Color.black.opacity(0.5))
                        .offset(y: 1.5)
                }
            }
        }
    }
}

struct LlamaProgressView_Previews: PreviewProvider {
    static var previews: some View {
        LlamaProgressView().environmentObject(AKRandomNumberFakerator())
    }
}
