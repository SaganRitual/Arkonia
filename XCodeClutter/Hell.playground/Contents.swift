import Foundation
var x = 0, y = 0

while x < 10 && y < 10 {
    defer { print("I ordered a cheeseburger x = \(x), y = \(y)") }

    if (2 * (x / 2)) == x { print("\(x) even") }

    x += 1
}
