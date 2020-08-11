import Foundation
import SwiftUI

class AKRandomNumberFakerator: ObservableObject {
    #if DEBUG
    @Published var histogramPublishedArray: [Double] =
        [0.15, 0.3, 0.45, 0.6, 0.75, 0.4, 0.35, 0.25, 0.15, 0.05]
    #else
    @Published var histogramPublishedArray: [Double] =
        .init(repeating: 0, count: 10)
    #endif

    @Published var isBusy = false
    @Published var isLloading = false
    @Published var isNormallizing = false
    @Published var llamaFullness = 0.0

    static var shared = AKRandomNumberFakerator()

    #if DEBUG
    static let cSamplesToGenerate = 2_000
    #else
    static let cSamplesToGenerate = 200_000
    #endif

    var normalizedSamples: ContiguousArray<Float>
    var uniformSamples: ContiguousArray<Float>

    let normalDistribution = NormalDistribution<Float>(mean: 0, standardDeviation: 3)
    let uniformDistribution = UniformFloatingPointDistribution(lowerBound: -1, upperBound: 1)

    var cSamplesGenerated = 0
    var cSamplesNormalized = 0
    var histogram = Histogram(10, .minusOneToOne)
    var maxFloat: Float = 0
    var onComplete: () -> Void = {}

    init() {
        normalizedSamples = .init(repeating: 0, count: AKRandomNumberFakerator.cSamplesToGenerate)
        uniformSamples = .init(repeating: 0, count: AKRandomNumberFakerator.cSamplesToGenerate)
    }

    func fillArrays(_ onComplete: @escaping () -> Void) {
        self.onComplete = onComplete

        isBusy = true
        isLloading = true
        arrayBatch()
    }

    func arrayBatch() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.005) {
            for ss in 0..<(AKRandomNumberFakerator.cSamplesToGenerate / 200) {
                let u = self.uniformDistribution.next(using: &ARC4RandomNumberGenerator.global)
                self.uniformSamples[self.cSamplesGenerated + ss] = Float(u)
                self.histogram.track(sample: u)

                let n = self.normalDistribution.next(using: &ARC4RandomNumberGenerator.global)
                self.normalizedSamples[self.cSamplesGenerated + ss] = n

                if abs(n) > abs(self.maxFloat) { self.maxFloat = n }
            }

            self.llamaFullness += 0.005
            self.cSamplesGenerated += AKRandomNumberFakerator.cSamplesToGenerate / 200

            let yValues = self.histogram.getScalarDistribution(reset: false)!

            // Scale to max value = 1.0 so the bars will be taller
            (0..<yValues.count).forEach { barSS in
                // not sure where the 2 is coming from, but the bars are 2x too tall
                self.histogramPublishedArray[barSS] =
                    Double(yValues[barSS]) / 2 * Double.random(in: 0.9..<1.0)  // To make them bounce; I know, it's silly
            }

            if self.cSamplesGenerated < AKRandomNumberFakerator.cSamplesToGenerate { self.arrayBatch() }
            else { self.isLloading = false; self.normalize() }
        }
    }

    func normalize() {
        isNormallizing = true
        llamaFullness = 0

        (0..<self.histogram.count).forEach {
            self.histogramPublishedArray[$0] = 0
        }

        normalizeBatch()
    }

    func normalizeBatch() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.005) {
            for ss in 0..<(AKRandomNumberFakerator.cSamplesToGenerate / 200) {
                var n = self.normalizedSamples[self.cSamplesNormalized + ss] / self.maxFloat
                if abs(n) == 1 { n = 0 }

                self.normalizedSamples[self.cSamplesNormalized + ss] = n
                self.histogram.track(sample: Double(n))
            }

            let yValues = self.histogram.getScalarDistribution(reset: false)!

            // Scale to max value = 1.0 so the bars will be taller
            (0..<yValues.count).forEach { barSS in
                // not sure where the 2 is coming from, but the bars are 2x too tall
                self.histogramPublishedArray[barSS] =
                    Double(yValues[barSS]) / 2 * Double.random(in: 0.9..<1.0)  // To make them bounce; I know, it's silly
            }

            self.llamaFullness += 0.005
            self.cSamplesNormalized += AKRandomNumberFakerator.cSamplesToGenerate / 200

            if self.cSamplesNormalized < AKRandomNumberFakerator.cSamplesToGenerate { self.normalizeBatch() }
            else {
                self.isNormallizing = false
                self.isBusy = false

                // Wait a little, so the UI can finish drawing the progress bar
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.01) {
                    self.onComplete()
                }
            }
        }
    }
}

struct AKRandomer: IteratorProtocol {
    typealias Element = Float

    enum Mode { case normal, uniform }

    init(_ mode: Mode = .normal) { self.mode = mode }

    let mode: Mode

    var ss: Int = Int.random(in: 0..<AKRandomNumberFakerator.cSamplesToGenerate)

    mutating func next() -> Float? {
        if mode == .uniform { return nextUniform() }

        defer { ss = (ss + 1) % AKRandomNumberFakerator.cSamplesToGenerate }

        return AKRandomNumberFakerator.shared.normalizedSamples[ss]
    }

    mutating private func nextUniform() -> Float? {
        defer { ss = (ss + 1) % AKRandomNumberFakerator.cSamplesToGenerate }
        return AKRandomNumberFakerator.shared.uniformSamples[ss]
    }

    mutating func bool() -> Bool { next()! < 0 }
    mutating func positive() -> Float { abs(next()!) }

    mutating func inRange(_ range: Range<Int>) -> Int {
        let offset = abs(next()!) * Float(range.count)
        return Int(offset) + range.lowerBound
    }

    mutating func inRange(_ range: Range<Float>) -> Float {
        let offset = abs(next()!) * Float(range.upperBound - range.lowerBound)
        return Float(offset) + range.lowerBound
    }
}
