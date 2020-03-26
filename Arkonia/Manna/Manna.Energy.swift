import SpriteKit

extension Manna.Energy {
    func getEnergyContentInJoules(_ indicatorFullness: CGFloat) -> CGFloat {
        let rate = Arkonia.mannaGrowthRateJoulesPerSecond
        let duration = CGFloat(Arkonia.mannaFullGrowthDurationSeconds)

        let energyContent: CGFloat = indicatorFullness * rate * duration
        Debug.log(level: 136) { "energy content \(energyContent)" }
        return energyContent
    }
}
