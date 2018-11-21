var symbolcase = [Character]()

for charCode in 0..<32 {
    let char = Character(UnicodeScalar(charCode)!)
    print(char)
    symbolcase.append(char)
}

print("'\(symbolcase)'")
