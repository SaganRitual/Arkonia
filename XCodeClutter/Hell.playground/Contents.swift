import Foundation

struct Trouble: CustomStringConvertible {
    var value = "0"
    var needUpdate = false
    
    var description: String { print(".", terminator: ""); return value }
    
    init(_ value: Double) {
        let truncated = Double(truncating: NSNumber(floatLiteral: value))
        self.value = String(format: "%.5f", truncated)
    }
    
    init?(_ value: String) {
        guard let d = Double(value) else { return nil }
        let truncated = Double(truncating: NSNumber(floatLiteral: d))
        self.value = String(format: "%.5f", truncated)
    }
}

let fortyTwo = Trouble(42)
print(fortyTwo.description)

let fortySomething = fortyTwo
print(fortySomething.description)
