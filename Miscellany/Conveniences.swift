import Foundation

func fatalErrorIf(_ condition: Bool, _ message: String) {
    if condition { fatalError(message) }
}

func guardlet<T>(_ wrapper: Optional<T>, _ message: String = "Unspecified") -> T {
    switch wrapper {
    case let .some(w): return w
    case .none: fatalError(message)
    }
}
