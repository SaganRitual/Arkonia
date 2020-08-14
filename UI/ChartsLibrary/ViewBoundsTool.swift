import SwiftUI

// With much gratitude to Javier at the SwiftUI Lab
// https://swiftui-lab.com/view-extensions-for-better-code-readability/
extension View {
    public func saveBounds(viewId: Int, coordinateSpace: CoordinateSpace = .global) -> some View {
        background(GeometryReader { proxy in
            Color.clear.preference(key: SaveBoundsPrefKey.self, value: [SaveBoundsPrefData(viewId: viewId, bounds: proxy.frame(in: coordinateSpace))])
        })
    }

    public func retrieveBounds(viewId: Int, _ rect: Binding<CGRect>) -> some View {
        onPreferenceChange(SaveBoundsPrefKey.self) { preferences in
            DispatchQueue.main.async {
                // The async is used to prevent a possible blocking loop,
                // due to the child and the ancestor modifying each other.
                let p = preferences.first(where: { $0.viewId == viewId })
                rect.wrappedValue = p?.bounds ?? .zero
            }
        }
    }

    func selectOnTap(_ color: Color) -> some View {
        modifier(SelectOnTap(color: color))
    }
}

struct SelectOnTap: ViewModifier {
    let color: Color

    func body(content: Content) -> some View { content.coordinateSpace(name: "line-chart-data-backdrop") }
}
struct SaveBoundsPrefData: Equatable {
    let viewId: Int
    let bounds: CGRect
}

struct SaveBoundsPrefKey: PreferenceKey {
    static var defaultValue: [SaveBoundsPrefData] = []

    static func reduce(value: inout [SaveBoundsPrefData], nextValue: () -> [SaveBoundsPrefData]) {
        value.append(contentsOf: nextValue())
    }

    typealias Value = [SaveBoundsPrefData]
}
