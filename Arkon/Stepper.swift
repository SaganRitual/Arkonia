import SpriteKit

class Stepper {
    let fishday: Fishday
    let metabolism: Metabolism
    let net: Net
    let nose: SKSpriteNode
    let sensorPad: SensorPad
    let spindle: Spindle
    let thorax: SKSpriteNode
    let tooth: SKSpriteNode

    var babyBumpIsShowing = false
    var canSpawn = false
    var currentTime: TimeInterval = 0
    var currentEntropyPerJoule: Double = 0
    var isDyingFromParasite = false
    var jumpSpec: JumpSpec?
    var jumpSpeed = 0.0
    var previousShiftOffset = AKPoint.zero

    class CensusData {
        var cAttacks = 0
        var cBloodBites = 0
        var cJumps = 0
        var cOffspring = 0
        var cVeggieBites = 0
    }

    var censusData = CensusData()

    var name: ArkonName { fishday.name }

    init(_ embryo: ArkonEmbryo) {
        self.fishday = embryo.fishday!
        self.metabolism = embryo.metabolism!
        self.net = embryo.net!
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
    var cAttacks:     Int { censusData.cAttacks }
    var cBloodBites:  Int { censusData.cBloodBites }
    var cJumps:       Int { censusData.cJumps }
    var cOffspring:   Int { censusData.cOffspring }
    var cVeggieBites: Int { censusData.cVeggieBites }
}

extension Stepper.CensusData {
    enum Datum { case attacks, bloodBites, jumps, offspring, veggieBites }

    func increment(_ datum: Datum) {
        Census.dispatchQueue.async {
            switch datum {
            case .attacks:     self.cAttacks += 1
            case .bloodBites:  self.cBloodBites += 1
            case .jumps:       self.cJumps += 1
            case .offspring:   self.cOffspring += 1
            case .veggieBites: self.cVeggieBites += 1
            }
        }
    }
}
