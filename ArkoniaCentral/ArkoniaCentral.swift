import SpriteKit

enum ArkoniaCentral {
}

extension SKSpriteNode {
    func getRandomPoint() -> CGPoint {
        let w = size.width / 2
        let h = size.height / 2

        let xRange = -w..<w
        let yRange = -h..<h

        return CGPoint.random(xRange: xRange, yRange: yRange)
    }
}
