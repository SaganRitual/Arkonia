import SpriteKit

enum ArkoniaCentral {
    static let cMotorNeurons = 8
    static let cSenseNeurons = 166
}

extension SKSpriteNode {

    func getRandomGridlet() -> Gridlet {
        let wGrid = Grid.dimensions.wGrid
        let hGrid = Grid.dimensions.hGrid

        let ak = AKPoint.random((-wGrid + 1)..<wGrid, (-hGrid + 1)..<hGrid)

        let gridlet = Gridlet.at(ak.x, ak.y)
        let wScene = CGFloat(Grid.dimensions.wSprite / 2)
        let hScene = CGFloat(Grid.dimensions.hSprite / 2)

        let lScene = gridlet.scenePosition.x - wScene
        let rScene = gridlet.scenePosition.x + wScene
        let bScene = gridlet.scenePosition.y - hScene
        let tScene = gridlet.scenePosition.y + hScene

        gridlet.randomScenePosition = CGPoint.random(
            xRange: lScene..<rScene, yRange: bScene..<tScene
        )

        gridlet.randomScenePosition = gridlet.scenePosition

        return gridlet
    }
}
