import SpriteKit

struct ColdKey: GridCellProtocol {
    init(for cell: GridCell) {
        debugDescription = cell.debugDescription
        gridPosition = cell.gridPosition
        manna = cell.manna
        ownerName = cell.ownerName
        stepper = cell.stepper
    }

    let debugDescription: String

    let gridPosition : AKPoint
    let ownerName: ArkonName
    let manna: Manna?
    let stepper: Stepper?
}

class NilKey: GridCellProtocol {
    //swiftlint:disable unused_setter_value
    let debugDescription: String = "NilKey"
    var gridPosition: AKPoint { get { AKPoint(x: -4444, y: -4444) } set { fatalError() } }
    var manna: Manna?  { get { nil } set { fatalError() } }
    var ownerName: ArkonName { get { ArkonName.offgrid } set { fatalError() } }
    var stepper: Stepper?  { get { nil } set { fatalError() } }
    //swiftlint:enable unused_setter_value
}
