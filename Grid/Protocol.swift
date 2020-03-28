import SpriteKit

enum LikeCSS { case right1, right2, bottom, left, top }

protocol GridCellProtocol {
    var gridPosition: AKPoint { get }
    var scenePosition: CGPoint { get }
    var randomScenePosition: CGPoint? { get }
    var stepper: Stepper? { get }

    var contents: GridCell.Contents { get }
}
