import SpriteKit

class Stepper {
    var birthday: TimeInterval = 0
    let metabolism: Metabolism
    let name: ArkonName
    let net: Net
    let netDisplay: NetDisplay?
    let nose: SKSpriteNode
    let sensorPad: SensorPad
    let thorax: SKSpriteNode
    let tooth: SKSpriteNode

    var babyBumpIsShowing = false
    var canSpawn = false
    var cFoodHits = 0
    var cJumps = 0
    var cOffspring = 0
    var currentTime: Int = 0
    var currentEntropyPerJoule: Double = 0
    var ingridCellAbsoluteIndex = 0
    var jumpSpec: JumpSpec?
    var jumpSpeed = 0.0
    var previousShiftOffset = AKPoint.zero

    var dispatch: Dispatch!

    init(_ embryo: ArkonEmbryo) {
        self.metabolism = embryo.metabolism!
        self.name = embryo.name!
        self.net = embryo.net!
        self.netDisplay = embryo.netDisplay
        self.nose = embryo.noseSprite!
        self.thorax = embryo.thoraxSprite!
        self.tooth = embryo.toothSprite!

        sensorPad = embryo.sensorPad!

        thorax.color = net.isCloneOfParent ? .green : .white
        nose.color = .blue

        self.dispatch = Dispatch(self)
    }

    deinit {
        Debug.log(level: 198) { "Stepper \(self.name) deinit" }
    }

    func detachBirthingCellForNewborn() -> IngridCellConnector {
        var localIndex = 1  // Try to drop the kid close by
        let birthingCell: IngridCell?
        let virtualScenePosition: CGPoint?

        if let j = sensorPad.getCorrectedTarget(candidateLocalIndex: localIndex) {
            localIndex = j.finalTargetLocalIx
            birthingCell = j.toCell
            virtualScenePosition = j.virtualScenePosition
        } else {
            birthingCell = sensorPad.thePad[localIndex]!.coreCell!
            virtualScenePosition = sensorPad.thePad[localIndex]!.virtualScenePosition
        }

        // Invalidate my reference to my offspring's cell; he now owns the lock
        sensorPad.thePad[localIndex] = IngridCellConnector()

        return IngridCellConnector(birthingCell!, virtualScenePosition)
    }
}
