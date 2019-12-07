import SpriteKit

enum ArkoniaCentral {
    static let masterScale = CGFloat(2)
    static let senseGridSide = 5
    static let cSenseGridlets = senseGridSide * senseGridSide
    static let cSenseNeurons = 2 * cSenseGridlets + 2
    static let cMotorNeurons = 9 - 1
    static let cMotorGridlets = cMotorNeurons + 1
}

struct AKPoint: Hashable, HasXY, CustomDebugStringConvertible {
    var debugDescription: String { return "(\(x), \(y))" }

    let x: Int; let y: Int

    init(_ point: AKPoint) { x = point.x; y = point.y }
    init(x: Int, y: Int) { self.x = x; self.y = y }

    static let zero = AKPoint(x: 0, y: 0)

    static func random(_ xRange: Range<Int>, _ yRange: Range<Int>) -> AKPoint {
        let xx = Int.random(in: xRange), yy = Int.random(in: yRange)
        return AKPoint(x: xx, y: yy)
    }

    static func + (_ lhs: AKPoint, _ rhs: AKPoint) -> AKPoint {
        return AKPoint(x: lhs.x + rhs.x, y: lhs.y + rhs.y)
    }

    static func - (_ lhs: AKPoint, _ rhs: AKPoint) -> AKPoint {
        return AKPoint(x: lhs.x - rhs.x, y: lhs.y - rhs.y)
    }

    static func * (_ lhs: AKPoint, _ rhs: Int) -> AKPoint {
        return AKPoint(x: lhs.x * rhs, y: lhs.y * rhs)
    }
}

struct Dimensions {
    let hGrid: Int
    let hPortal: Int
    let hSprite: Int
    let wGrid: Int
    let wPortal: Int
    let wSprite: Int

    init(_ hGrid: Int, _ hPortal: Int, _ hSprite: Int, _ wGrid: Int, _ wPortal: Int, _ wSprite: Int) {
        self.hGrid = hGrid
        self.hPortal = hPortal
        self.hSprite = hSprite
        self.wGrid = wGrid
        self.wPortal = wPortal
        self.wSprite = wSprite
    }

    static func setDimensions(_ portal: SKSpriteNode) -> Dimensions {
        let tAtlas = SKTextureAtlas(named: "Arkons")
        let tTexture = tAtlas.textureNamed("neuron-plain")

        let hSprite = Int(tTexture.size().height / (2 * ArkoniaCentral.masterScale))
        let wSprite = Int(tTexture.size().width / (2 * ArkoniaCentral.masterScale))

        let hPortal = Int((2 / ArkoniaCentral.masterScale) * portal.size.height) - hSprite
        let wPortal = Int((2 / ArkoniaCentral.masterScale) * portal.size.width) - wSprite
        let hGrid = Int(hPortal / hSprite)
        let wGrid = Int(wPortal / wSprite)

        Log.L.write("(wGrid x hGrid) = (\(wGrid) x \(hGrid)), (wPortal x hPortal) = (\(wPortal) x \(hPortal)), (wSprite x hSprite) = (\(wSprite) x \(hSprite))", level: 40)

        return Dimensions(hGrid, hPortal, hSprite, wGrid, wPortal, wSprite)
    }
}

extension SKSpriteNode {

    func getKeyField(_ cellContents: GridCell.Contents, require: Bool = true) -> Any? {
        func failIf(_ sub: String) {
            if require { Log.L.write("getKeyField failed to get \(sub)"); fatalError() }
        }

        if name == nil { failIf("'sprite name'"); return nil }

        guard let userData = self.userData
            else { failIf("'user data'"); return nil }

        let spriteKey: SpriteUserDataKey
        switch cellContents {
        case .arkon: spriteKey = .stepper
        case .manna: spriteKey = .manna
        default: fatalError()
        }

        guard let entry = userData[spriteKey]
            else { failIf("'entry' for \(spriteKey)"); return nil }

        return entry
    }

    func getManna(require: Bool = true) -> Manna? {
        if let manna = getKeyField(.manna, require: require) as? Manna
            { return manna }

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
