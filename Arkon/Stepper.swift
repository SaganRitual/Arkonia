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
    var parentWeights: [Double]?
    var previousShiftOffset = AKPoint.zero
    var sensorPad: SensorPad
    var thorax: SKSpriteNode!
    var tooth: SKSpriteNode!

    var babyBumpIsShowing = false
    var canSpawn = false
    var jumpSpeed = 0.0
    var jumpSpec: JumpSpec?

    weak var parentNet: Net?

    var currentTime: Int = 0
    var currentEntropyPerJoule: Double = 0

    init(_ embryo: ArkonEmbryo) {
        self.metabolism = embryo.metabolism
        self.name = embryo.name!
        self.net = embryo.net
        self.netDisplay = embryo.netDisplay
        self.nose = embryo.noseSprite!
        self.thorax = embryo.thoraxSprite!
        self.tooth = embryo.toothSprite

        sensorPad = SensorPad(self.net.netStructure)

        thorax.color = net!.isCloneOfParent ? .green : .white
        nose!.color = .blue

        self.dispatch = Dispatch(self)
    }

    deinit {
        Debug.log(level: 198) { "Stepper \(self.name) deinit" }
    }

    func detachBirthingCellForNewborn() -> IngridCellDescriptor {
        guard let localIndex = (1..<net.netStructure.sensorPadCCells).first(where: { sensorPadSS in
            let c = sensorPad[sensorPadSS].coreCell
            let d = (c == nil) ? "no lock" : "\(c!)"
            Debug.log(level: 198) { "candidate birth cell \(sensorPadSS) \(d), parent \(self.name)" }
            guard let candidateCell = sensorPad[sensorPadSS].coreCell else { return false }
            let contents = Ingrid.shared.getContents(in: candidateCell)
            return contents == .empty || contents == .manna
        }) else { fatalError("No usable cells for newborn?") }

        let birthingCell = sensorPad[localIndex].coreCell!
        let virtualScenePosition = sensorPad[localIndex].virtualScenePosition

        Debug.log(level: 198) { "detachRandomCell absoluteIx \(birthingCell.absoluteIndex) localIx \(localIndex)" }

        // Invalidate my reference to my offspring's cell; he now owns the lock
        sensorPad[localIndex] = IngridCellDescriptor()

        return IngridCellDescriptor(birthingCell, virtualScenePosition)
    }
}
