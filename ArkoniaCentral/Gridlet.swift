import SpriteKit

class Gridlet: GridletProtocol, Equatable {

    enum Contents: Double { case arkon, manna, nothing }

    let gridPosition: AKPoint
    let scenePosition: CGPoint
    var randomScenePosition: CGPoint?

    var contents = Contents.nothing { didSet { previousContents = oldValue } }
    weak var connector: Connector?
    var previousContents = Contents.nothing
    var gridletOwner: String?
    weak var sprite: SKSpriteNode?

    init(gridPosition: AKPoint, scenePosition: CGPoint) {
        self.gridPosition = gridPosition
        self.scenePosition = scenePosition
    }

    deinit {
//        print("~Gridlet")
    }

    func disengageGridlet(_ runType: Dispatch.RunType) {
        assert(runType == .barrier)
        self.gridletIsEngaged = false
    }

    func releaseGridlet() {
        Grid.shared.concurrentQueue.async(flags: .barrier) { [unowned self] in
            guard self.gridletIsEngaged else { return }

            if self.sprite == nil { print("nil2 no sprite", self.gridPosition) }
            else {
                if let st = Stepper.getStepper(from: self.sprite!, require: false) {
                    print("nil2", st.name)
                } else {
                    print("nil3 no sprite", self.gridPosition)
                }
            }

            self.sprite = nil
            self.contents = .nothing
            self.gridletIsEngaged = false
        }
    }
}
