import Foundation
import SpriteKit

class Dashboard {
    var node: SKNode
    var quadrants: [Quadrant]

    init(node: SKNode, quadrants: [Quadrant]) {
        self.node = node
        self.quadrants = quadrants
    }
}

class Quadrant {
    var monitor: SKSpriteNode?
    let quadrantPosition: CGPoint

    init(monitor: SKSpriteNode, quadrantPosition: CGPoint) {
        self.monitor = monitor
        self.quadrantPosition = quadrantPosition
    }
}

class HUD {
    enum MonitorPrototype: Int, CaseIterable {
        case report = 0, nothing = 1, barchart = 2, linegraph = 3
    }

    static private let prototypeNames: [MonitorPrototype: String] = [
        .report: "report_monitor_prototype",
        .barchart: "barchart_monitor_prototype",
        .linegraph: "linegraph_monitor_prototype",
        .nothing: "some_other_monitor_prototype"
    ]

    private var dashboards = [Dashboard]()
    private let scene: SKScene

    init(scene: SKScene) {
        self.scene = scene

        let prototypesContainer = scene.childNode(withName: "dashboard1")!
        let prototypes = HUD.unpackPrototypes(prototypesContainer, scene: scene)

        dashboards.append(Dashboard(node: prototypesContainer, quadrants: prototypes))

        let placeholdersContainer = scene.childNode(withName: "dashboard2")!
        let placeholders = HUD.unpackPlaceholders(placeholdersContainer, scene: scene)

        dashboards.append(Dashboard(node: placeholdersContainer, quadrants: placeholders))
    }

    func getNetPortal() -> SKNode {
        return scene.childNode(withName: "net_portal")!
    }

    func getPrototype(_ whichOne: MonitorPrototype) -> SKNode {
        return dashboards[0].quadrants[whichOne.rawValue].monitor!
    }

    func placeMonitor(_ monitor: SKNode, dashboard whichDashboard: Int, quadrant whichQuadrant: Int) {
        let dashboard = dashboards[whichDashboard]
        let quadrant = dashboard.quadrants[whichQuadrant]

        quadrant.monitor?.removeFromParent()

        monitor.position = quadrant.quadrantPosition
        dashboard.node.addChild(monitor)
    }

    func releasePrototype(_ thePrototype: SKNode) {
        thePrototype.removeFromParent()
    }

    static private func unpackPlaceholders(_ dashboard: SKNode, scene: SKScene) -> [Quadrant] {
        let quadrants: [Quadrant] = (0..<4).map {
            let node = dashboard.childNode(withName: "placeholder\($0)")
            let placeholder = (node as? SKSpriteNode)!

            let quadrant = Quadrant(
                monitor: placeholder, quadrantPosition: placeholder.position
            )

            return quadrant
        }

        return quadrants
    }

    static private func unpackPrototypes(_ dashboard: SKNode, scene: SKScene) -> [Quadrant] {
        let quadrants: [Quadrant] = MonitorPrototype.allCases.map { monitorType in
            let name = prototypeNames[monitorType]!
            let node = dashboard.childNode(withName: name)
            let monitorPrototype = (node as? SKSpriteNode)!

            let quadrant = Quadrant(
                monitor: monitorPrototype, quadrantPosition: monitorPrototype.position
            )

            return quadrant
        }

        return quadrants
    }
}
