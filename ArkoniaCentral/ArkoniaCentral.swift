import SpriteKit

enum ArkoniaCentral {
    static let cMotorNeurons = 5
    static let cSenseNeurons = 12
}

extension SKSpriteNode {
//    func getRandomPoint() -> CGPoint {
//        let w = size.width / 2 / xScale
//        let h = size.height / 2 / yScale
//
//        let xRange = -w..<w
//        let yRange = -h..<h
//
//        return CGPoint.random(xRange: xRange, yRange: yRange)
//    }

    func getRandomPoint() -> CGPoint {
        let wGrid = Griddle.dimensions.wGrid
        let hGrid = Griddle.dimensions.hGrid

        let ak = AKPoint.random(-wGrid..<wGrid, -hGrid..<hGrid)

        let gridlet = Gridlet.at(ak.x, ak.y)
        let wScene = CGFloat(Griddle.dimensions.wSprite / 2)
        let hScene = CGFloat(Griddle.dimensions.hSprite / 2)

        let lScene = gridlet.scenePosition.x - wScene
        let rScene = gridlet.scenePosition.x + wScene
        let bScene = gridlet.scenePosition.y - hScene
        let tScene = gridlet.scenePosition.y + hScene

        let sp = CGPoint.random(xRange: lScene..<rScene, yRange: bScene..<tScene)
        return sp
    }
}
