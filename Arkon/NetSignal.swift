import SpriteKit

struct KarambaNetSignal {
    mutating func go(karamba: Karamba) {
//            print("go1", arkon.selectoid.fishNumber)

        let workAction = SKAction.run({
            let sensoryInputs = karamba.stimulus()
            let motorOutputs = karamba.core.net.getMotorOutputs(sensoryInputs)
            let metabolism = (karamba.metabolism as? Metabolism)!

            Karamba.brainlyManeuverEnd(
                sprite: karamba.sprite, metabolism: metabolism, motorOutputs: motorOutputs
            )

        }, queue: karamba.core.netQueue)

//            print("go2", arkon.selectoid.fishNumber)
        let waitAction = SKAction.wait(forDuration: 0.02)
        let sequence = SKAction.sequence([waitAction, workAction])

        karamba.sprite.run(sequence)
//            print("go3", arkon.selectoid.fishNumber)
    }
}
