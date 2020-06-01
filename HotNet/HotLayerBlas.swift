import Accelerate

class HotLayerBlas {
    let cNeuronsIn: Int
    let cNeuronsOut: Int
    let pBiases: UnsafePointer<Float>
    let pNeuronsIn: UnsafePointer<Float>
    let pNeuronsOut: UnsafeMutablePointer<Float>
    let pWeights: UnsafePointer<Float>

    init(
        _ cNeuronsIn: Int,
        _ pNeuronsIn: UnsafePointer<Float>,
        _ pBiases: UnsafePointer<Float>,
        _ pWeights: UnsafePointer<Float>,
        _ cNeuronsOut: Int,
        _ pNeuronsOut: UnsafeMutablePointer<Float>
    ) {
        self.cNeuronsIn = cNeuronsIn
        self.cNeuronsOut = cNeuronsOut

        self.pBiases = pBiases
        self.pNeuronsIn = pNeuronsIn
        self.pNeuronsOut = pNeuronsOut
        self.pWeights = pWeights
    }

    func driveSignal() {
        // The sgemv function below does y = alpha * Ax + beta * y; copy
        // the biases to y here so the sgemm result will be added to them

        cblas_scopy(
            Int32(cNeuronsOut), // Number of elements in the vectors
            pBiases,            // Copy from biases vector
            Int32(1),           // Stride -- take each nth element, we want all
            pNeuronsOut,        // Copy to neurons output
            Int32(1)            // Stride for output -- write to each nth entry
        )

        Debug.log(level: 187) {
            "scopy: \(cNeuronsOut), \(pBiases), 1, \(pNeuronsOut), 1"
        }

        cblas_sgemv(
            CblasRowMajor, CblasNoTrans,
            Int32(cNeuronsIn),  // Number of rows in A, that is, the weights
            Int32(cNeuronsOut), // Number of columns in A
            Float(1),           // alpha (scale for Ax result)
            pWeights,           // The matrix A
            Int32(cNeuronsOut), // Size of first dimension of A, aka "pitch", aka "lda"
            pNeuronsIn,         // The vector x
            Int32(1),           // Stride for x -- take each nth element, we want all
            Float(1),           // beta (scale for y)
            pNeuronsOut,        // The output vector y
            Int32(1)            // Stride for y -- write to each nth entry
        )

        Debug.log(level: 187) {
            "sgemv: CblasRowMajor, CblasNoTrans, \(cNeuronsIn), \(cNeuronsOut), 1, \(pWeights), \(cNeuronsOut), \(pNeuronsIn), 1, 1, \(pNeuronsOut), 1"
        }

        // I thought there would be a function in the blas library for applying
        // a function to each element. I guess not
        (0..<cNeuronsOut).forEach {
            let a = pNeuronsOut[$0]
            let b = Net.logistic(a)
            self.pNeuronsOut[$0] = b
        }
    }
}
