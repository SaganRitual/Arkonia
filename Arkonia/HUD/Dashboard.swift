import SpriteKit

class DashboardFactory {
    let hud: HUD

    init(hud: HUD) { self.hud = hud }

    func newDashboard() -> SKSpriteNode { return (hud.prototypes.dashboard.copy() as? SKSpriteNode)! }
}
