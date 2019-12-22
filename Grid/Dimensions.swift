import SpriteKit

struct Dimensions {
    let hGrid: Int
    let hPortal: Int
    let hypotenuse: Double
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

        let d = Double(wPortal * wPortal + hPortal * hPortal)
        self.hypotenuse = sqrt(d)
    }

    static func setDimensions(_ portal: SKSpriteNode) -> Dimensions {
        let tAtlas = SKTextureAtlas(named: "Arkons")
        let tTexture = tAtlas.textureNamed("neuron-plain")

        let hSprite = Int(tTexture.size().height / (2 * ArkoniaCentral.masterScale))
        let wSprite = Int(tTexture.size().width / (2 * ArkoniaCentral.masterScale))

        let hPortal = Int(2 * portal.size.height / ArkoniaCentral.masterScale) - hSprite * 2
        let wPortal = Int(2 * portal.size.width / ArkoniaCentral.masterScale) - wSprite * 2
        let hGrid = Int(hPortal / hSprite)
        let wGrid = Int(wPortal / wSprite)

        Log.L.write("(wGrid x hGrid) = (\(wGrid) x \(hGrid)), (wPortal x hPortal) = (\(wPortal) x \(hPortal)), (wSprite x hSprite) = (\(wSprite) x \(hSprite))", level: 55)

        return Dimensions(hGrid, hPortal, hSprite, wGrid, wPortal, wSprite)
    }
}
