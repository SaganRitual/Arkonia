import SpriteKit

extension SKSpriteNode {
    func getKeyField(_ spriteKey: SpriteUserDataKey, require: Bool = true) -> Any? {
        func failIf(_ sub: String) {
            if require {
                Debug.log { "getKeyField failed to get \(sub) for \(six(name))" }
                fatalError()
            }
        }

        guard let userData = self.userData
            else { failIf("'user data'"); return nil }

        guard let entry = userData[spriteKey]
            else { failIf("'entry' for \(spriteKey)"); return nil }

        return entry
    }
}
