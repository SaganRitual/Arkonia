import SpriteKit

enum ArkoniaCentral {
    static let cMotorNeurons = 5
    static let cSenseNeurons = 12
}

extension SKSpriteNode {
    func getRandomPoint() -> CGPoint {
        let w = size.width / 2 / xScale
        let h = size.height / 2 / yScale

        let xRange = -w..<w
        let yRange = -h..<h

        return CGPoint.random(xRange: xRange, yRange: yRange)
    }
}
