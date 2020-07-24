import Foundation
import SwiftUI

class AKRandomNumberFakerator: ObservableObject {
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
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.01) {
            for ss in 0..<(AKRandomNumberFakerator.cSamplesToGenerate / 100) {
                self.normalizedSamples[self.cSamplesGenerated + ss] = self.normalDistribution.next(using: &ARC4RandomNumberGenerator.global)
                self.uniformSamples[self.cSamplesGenerated + ss] = Float(self.uniformDistribution.next(using: &ARC4RandomNumberGenerator.global))

                if abs(self.normalizedSamples[self.cSamplesGenerated + ss]) > self.maxFloat {
                    self.maxFloat = self.normalizedSamples[self.cSamplesGenerated + ss]
                }
            }

            self.llamaFullness += 0.01
            self.cSamplesGenerated += AKRandomNumberFakerator.cSamplesToGenerate / 100

            if self.cSamplesGenerated < AKRandomNumberFakerator.cSamplesToGenerate { self.arrayBatch() }
            else { self.isLloading = false; self.normalize() }
        }
    }

    func normalize() {
        isNormallizing = true
        llamaFullness = 0
        normalizeBatch()
    }

    func normalizeBatch() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.01) {
            for ss in 0..<(AKRandomNumberFakerator.cSamplesToGenerate / 100) {
                self.normalizedSamples[self.cSamplesNormalized + ss] /= self.maxFloat
                if abs(self.normalizedSamples[self.cSamplesNormalized + ss]) == 1 {
                    self.normalizedSamples[self.cSamplesNormalized + ss] = 0
                }
            }

            self.llamaFullness += 0.01
            self.cSamplesNormalized += AKRandomNumberFakerator.cSamplesToGenerate / 100

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
