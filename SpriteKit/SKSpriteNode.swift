import SpriteKit

extension SKSpriteNode {
    var setContentsCallback: (() -> Void)? {
        return getKeyField(.setContentsCallback, require: false) as? (() -> Void)
    }

    func getKeyField() -> AKPoint? {
        return getKeyField(.injectedAt) as? AKPoint
    }

    func getKeyField(_ spriteKey: SpriteUserDataKey, require: Bool = true) -> Any? {
        func failIf(_ sub: String) {
            if require { Debug.log("getKeyField failed to get \(sub) for \(six(name))"); fatalError() }
        }

        guard let userData = self.userData
            else { failIf("'user data'"); return nil }

        guard let entry = userData[spriteKey]
            else { failIf("'entry' for \(spriteKey)"); return nil }

        return entry
    }

    func getKeyField(_ cellContents: GridCell.Contents, require: Bool = true) -> Any? {
        func failIf(_ sub: String) {
            if require { Debug.log("getKeyField failed to get \(sub) for \(six(name))"); fatalError() }
        }

        guard let userData = self.userData
            else { failIf("'user data'"); return nil }

        let spriteKey: SpriteUserDataKey
        switch cellContents {
        case .arkon: spriteKey = .stepper
        case .manna: spriteKey = .manna
        default: spriteKey = .uuid
        }

        guard let entry = userData[spriteKey]
            else { failIf("'entry' for \(spriteKey)"); return nil }

        return entry
    }

    func getManna(require: Bool = true) -> Manna? {
        if let manna = getKeyField(SpriteUserDataKey.manna, require: require) as? Manna
            { return manna }

        if require { fatalError() }
        return nil
    }

    func getSpriteName(require: Bool = true) -> String? {
        if let name = getKeyField(.uuid, require: require) as? String
            { return name }

        if require { fatalError() }
        return nil
    }

    func getStepper(require: Bool = true) -> Stepper? {
        if let stepper = getKeyField(.arkon, require: require) as? Stepper
            { return stepper }

        if require { fatalError() }
        return nil
    }
}
