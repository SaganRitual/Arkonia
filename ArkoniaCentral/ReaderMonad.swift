import Foundation
class Reader<E, A> {

    let g: (E) -> A

    // closure as parameters are non-escaping by default in Swift 3:
    // https://github.com/apple/swift-evolution/blob/master/proposals/0103-make-noescape-default.md
    init(_ g: @escaping (E) -> A) {
        self.g = g
    }
    func run(_ e: E) -> A {
        return g(e)
    }
    func map<B>(_ f: @escaping (A) -> B) -> Reader<E, B> {
        return Reader<E, B>{ e in f(self.g(e)) }
    }
    func flatMap<B>(_ f: @escaping (A) -> Reader<E, B>) -> Reader<E, B> {
        return Reader<E, B>{ e in f(self.g(e)).g(e) }
    }
}
