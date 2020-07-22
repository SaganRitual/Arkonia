import SpriteKit

class Stepper {
    let fishday: Fishday
    let metabolism: Metabolism
    let net: Net
    let netDisplay: NetDisplay?
    let nose: SKSpriteNode
    let sensorPad: SensorPad
    let spindle: Spindle
    let thorax: SKSpriteNode
    let tooth: SKSpriteNode

    var babyBumpIsShowing = false
    var canSpawn = false
    var currentTime: TimeInterval = 0
    var currentEntropyPerJoule: Double = 0
    var jumpSpec: JumpSpec?
    var jumpSpeed = 0.0
    var previousShiftOffset = AKPoint.zero

    class CensusData {
        var cFoodHits = 0
        var cJumps = 0
        var cOffspring = 0
    }

    var censusData = CensusData()

    var name: ArkonName { fishday.name }

    init(_ embryo: ArkonEmbryo) {
        self.fishday = embryo.fishday!
        self.metabolism = embryo.metabolism!
        self.net = embryo.net!
        self.netDisplay = embryo.netDisplay
        self.nose = embryo.noseSprite!
        self.spindle = embryo.spindle!
        self.thorax = embryo.thoraxSprite!
        self.tooth = embryo.toothSprite!

        self.sensorPad = embryo.sensorPad!

        thorax.color = net.isCloneOfParent ? .green : .white
        nose.color = .blue
    }
}

extension Stepper {
    var cFoodHits:  Int { censusData.cFoodHits }
    var cJumps:     Int { censusData.cJumps }
    var cOffspring: Int { censusData.cOffspring }
}

extension Stepper.CensusData {
    enum Datum { case foodHits, jumps, offspring }

    func increment(_ datum: Datum) {
        Census.dispatchQueue.async {
            switch datum {
            case .foodHits:  self.cFoodHits += 1
            case .jumps:     self.cJumps += 1
            case .offspring: self.cOffspring += 1
            }
        }
    }
}
