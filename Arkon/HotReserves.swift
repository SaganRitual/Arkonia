import Accelerate
import CoreGraphics

class HotReserve {
    enum Subset: Int, CaseIterable { case all, fungible }
    enum Reserve: Int, CaseIterable { case bone, fat, ready, spawn, stomach }

    var values = [Double](repeating: 0, count: Reserve.allCases.count)
    var pValues: UnsafePointer<Double>

    func sum(_ subset: Subset) -> CGFloat {
        switch subset {
        case .all: return CGFloat(cblas_dasum(Int32(values.count), pValues, 1))
        case .fungible:
            let fpValues = pValues.advanced(by: 1)
            return CGFloat(cblas_dasum(Int32(2), fpValues, 1))
        }
    }

    var bone: Double {
        get { values[Reserve.bone.rawValue] }
        set { values[Reserve.bone.rawValue] = newValue }
    }

    var fat: Double {
        get { values[Reserve.fat.rawValue] }
        set { values[Reserve.fat.rawValue] = newValue }
    }

    var ready: Double {
        get { values[Reserve.ready.rawValue] }
        set { values[Reserve.ready.rawValue] = newValue }
    }

    var spawn: Double {
        get { values[Reserve.spawn.rawValue] }
        set { values[Reserve.spawn.rawValue] = newValue }
    }

    var stomach: Double {
        get { values[Reserve.stomach.rawValue] }
        set { values[Reserve.stomach.rawValue] = newValue }
    }

    init() {
        pValues = UnsafePointer(values)
    }
}
