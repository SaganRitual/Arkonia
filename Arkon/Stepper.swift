import SpriteKit

class Stepper {
    var birthday: TimeInterval = 0
    var cFoodHits = 0
    var cJumps = 0
    var cOffspring = 0
    var dispatch: Dispatch!
    var ingridCellAbsoluteIndex = 0
    var isTurnabouted: Bool = false
    var metabolism: Metabolism!
    let name: ArkonName
    var net: Net!
    var netDisplay: NetDisplay?
    var nose: SKSpriteNode!
    weak var parentStepper: Stepper?
    var parentWeights: [Double]?
    var previousShiftOffset = AKPoint.zero
    var sensorPad: UnsafeMutablePointer<IngridCellDescriptor>
    var thorax: SKSpriteNode!
    var tooth: SKSpriteNode!

    var babyBumpIsShowing = false
    var canSpawn = false
    var jumpSpeed = 0.0
    var jumpSpec: JumpSpec?

    weak var parentNet: Net?

    var currentTime: Int = 0
    var currentEntropyPerJoule: Double = 0

    init(_ embryo: Spawn, needsNewDispatch: Bool = false) {
        self.metabolism = embryo.metabolism
        self.name = embryo.embryoName!
        self.net = embryo.net
        self.netDisplay = embryo.netDisplay
        self.nose = embryo.newbornNose
        self.thorax = embryo.newbornThorax!
        self.tooth = embryo.newbornTooth

        let c = self.net.netStructure.cCellsWithinSenseRange
        self.sensorPad = .allocate(capacity: c)
        self.sensorPad.initialize(repeating: IngridCellDescriptor(), count: c)

        if needsNewDispatch { self.dispatch = Dispatch(self) }
    }

    func detachRandomCellForNewborn() -> IngridCellDescriptor {
        let bp =  UnsafeMutableBufferPointer(
            start: sensorPad, count: net.netStructure.cCellsWithinSenseRange
        )

        let hotCell = bp.compactMap({ $0.cell }).randomElement()!
        let localIndex = bp.firstIndex(where: { $0.absoluteIndex == hotCell.absoluteIndex })!

        let virtualScenePosition = bp[localIndex].virtualScenePosition

        Debug.log(level: 195) { "detachRandomCell absoluteIx \(hotCell.absoluteIndex) localIx \(localIndex)" }

        // Invalidate my reference to my offspring's cell; he now owns the lock
        bp[localIndex] = IngridCellDescriptor()

        return IngridCellDescriptor(hotCell, virtualScenePosition)
    }
}
