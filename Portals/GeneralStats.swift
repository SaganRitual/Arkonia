import SpriteKit

struct GeneralStats {
    typealias Updater = () -> String

    static var textFields = [[SKLabelNode]]()

    init(_ statsPortal: SKSpriteNode) {
        GeneralStats.init_(statsPortal: statsPortal)
    }

    static func init_(statsPortal: SKSpriteNode) {
        let generalPurposePortalNames: [(String, String)] = (0..<6).map {
            let labelSetName = String(format: "stats%02d", $0)
            let subportalName = String(format: labelSetName + "Subportal", $0)
            return (subportalName, labelSetName)
        }

        var llss = 0
        for (ss, portalNames) in zip(0..., generalPurposePortalNames) {
            let subportalName = portalNames.0
            let labelSetName = portalNames.1

            GeneralStats.textFields.append([SKLabelNode]())

            guard let subportalSprite =
                statsPortal.childNode(withName: subportalName) as? SKSpriteNode
                else { preconditionFailure() }

            //            let llamaPhrases = [
            //                "Llamas: %d", "Anti-llamas: %d", "Uncle llamas: %d", "Alibaba llamas: %d",
            //                "Squeako llamas: %d", "MAGA llamas: %d", "MARA llamas: %d", "Yo llama: %d",
            //                "<Socialism!>", "Idle hands: %d", "Card hands: %d", "High hands: %d",
            //                "Desert hands: %d", "Dessert Hands %d", "LL Beans: %d", "Jellies: %d",
            //                "Bellies: %d"
            //            ]

            let saveCuzImTiredOfTheMath = subportalSprite.frame.size
            subportalSprite.xScale = 0.75
            subportalSprite.size = saveCuzImTiredOfTheMath
            subportalSprite.enumerateChildNodes(withName: labelSetName) { node, _ in
                guard let n = node as? SKLabelNode else { preconditionFailure() }
                n.color = .brown
                n.text = ""
                n.position.x = -subportalSprite.size.width / 1.75
                GeneralStats.textFields[ss].append(n)

                llss += 1
            }
        }
    }

    func setUpdater(subportal: Int, field: Int, _ getText: @escaping Updater) {
        let delayAction = SKAction.wait(forDuration: 1.0)
        let node = GeneralStats.textFields[subportal][field]

        let updateAction = SKAction.run { node.text = getText() }
        let updateOncePerSecond = SKAction.sequence([delayAction, updateAction])

        let updateForever = SKAction.repeatForever(updateOncePerSecond)

        node.run(updateForever)
    }
}
