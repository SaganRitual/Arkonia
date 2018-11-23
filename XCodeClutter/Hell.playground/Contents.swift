import Foundation

func tanh(_ input: Double) -> Double {
    return 1.0
}

typealias NeuronOutputFunction = (Double) -> Double
class Neuron {
    let outputFunction: NeuronOutputFunction
    
    init() {
        outputFunction = tanh
    }
}

let n = Neuron()

print(n.outputFunction(1))
