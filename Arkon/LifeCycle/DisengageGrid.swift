extension Stepper {
    func disengageGrid() {
        MainDispatchQueue.async {
            Debug.log(level: 206) { "disengageGrid" }
            Debug.debugColor(self, .blue, .yellow)

            self.jumpSpec = nil

            self.sensorPad.disengageSensorPad(self.engageGrid)
        }
    }
}
