import Accelerate
import CoreGraphics

class HotReserve {
    enum Subset: Int, CaseIterable { case all, fungible }
    enum Reserve: Int, CaseIterable { case bone, fat, ready, spawn, stomach }

    var values = [Double](repeating: 0, count: Reserve.allCases.count)
    var pValues: UnsafePointer<Double>

    var cachedSum: CGFloat? // Profiler says we spend a lot of time getting the sum

    func sum(_ subset: Subset) -> CGFloat {
        if let s = cachedSum { return s }

        switch subset {
        case .all: cachedSum = CGFloat(cblas_dasum(Int32(values.count), pValues, 1))
        case .fungible:
            let fpValues = pValues.advanced(by: 1)
            cachedSum = CGFloat(cblas_dasum(Int32(2), fpValues, 1))
        }

        return cachedSum!
    }

    var bone: Double {
        get { values[Reserve.bone.rawValue] }
        set { values[Reserve.bone.rawValue] = newValue; cachedSum = nil }
    }

    var fat: Double {
        get { values[Reserve.fat.rawValue] }
        set { values[Reserve.fat.rawValue] = newValue; cachedSum = nil }
    }

    var ready: Double {
        get { values[Reserve.ready.rawValue] }
        set { values[Reserve.ready.rawValue] = newValue; cachedSum = nil }
    }

    var spawn: Double {
        get { values[Reserve.spawn.rawValue] }
        set { values[Reserve.spawn.rawValue] = newValue; cachedSum = nil }
    }

    var stomach: Double {
        get { values[Reserve.stomach.rawValue] }
        set { values[Reserve.stomach.rawValue] = newValue; cachedSum = nil }
    }

    init() {
        pValues = UnsafePointer(values)
    }
}
