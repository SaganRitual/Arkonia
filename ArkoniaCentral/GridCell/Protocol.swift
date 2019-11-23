import SpriteKit

enum LikeCSS { case right, bottom, left, top }

protocol GridCellProtocol {
    var gridPosition: AKPoint { get }
    var scenePosition: CGPoint { get }
    var randomScenePosition: CGPoint? { get }
    var sprite: SKSpriteNode? { get }

    var contents: GridCell.Contents { get }
    var ownerName: String? { get }
}

extension GridCellProtocol {

    // swiftlint:disable cyclomatic_complexity
    func getGridPointByIndex(_ index: Int, absolute: Bool = true) -> AKPoint {
        if index == 0 { return absolute ? self.gridPosition : AKPoint.zero }

        var ring = 1
        for s in stride(from: 1, to: Int.max, by: 2) {
            if index < ((s + 2) * (s + 2)) { break }

            ring += 1
        }

        var x = ring, y = 0, whichSide = LikeCSS.right

        var nudge: (() -> Void)!
        func decY() { nudge = { y -= 1 } }
        func decX() { nudge = { x -= 1 } }
        func incY() { nudge = { y += 1 } }
        func incX() { nudge = { x += 1 } }
        func nop()  { nudge = nil }

        for ugly in 1...index {
//            Log.L.write("pre ", index, whichSide, x, y)
            switch whichSide {
            case .right:
                if y <= -ring { whichSide = .bottom; decX() } else { decY() }

            case .bottom:
                if x <= -ring { whichSide = .left; incY() } else { decX() }

            case .left:
                if y >= ring { whichSide = .top; incX() } else { incY() }

            case .top:
                if x >= ring { whichSide = .right; decY() }  else { incX() }
            }

            if ugly < index { nudge() }

//            Log.L.write("post", index, whichSide, x, y)
        }

        let reference = absolute ? AKPoint(gridPosition) : AKPoint.zero
        let result = reference + AKPoint(x: x, y: y)
//        Log.L.write("index \(index), reference \(String(describing: reference)), result \(String(describing: result))")
        return result
    }
    // swiftlint:enable cyclomatic_complexity
}
