import Foundation

protocol IndexedBuffer {

    associatedtype T
    var size: Int { get }

    init(size: Int)
    mutating func put(value: T, at index: Int) -> Int
    func get(at index: Int) -> T?
    mutating func del(at index: Int) -> T?
}

public struct IndexedRingBuffer<T> : IndexedBuffer {

    fileprivate var array: [T?]
    public let size: Int

    /** Using pthread_mutex_t is still the fastest way to lock access to the array
     (see: https://ipfs.io/ipfs/Qmb7gbmBtiUXgY5x5kU2SiaXUeoCvRm14f8V5SLr6ivDqG) **/
    fileprivate var mutex = pthread_mutex_t()

    public init(size: Int) {

        self.size = size
        array = [T?](repeating: nil, count: size)

        pthread_mutex_init(&mutex, nil)
    }

    /** Put the given value in the buffer at the index modulo buffer size. **/
    @discardableResult
    public mutating func put(value: T, at index: Int) -> Int {

        let modIndex = index % size

        pthread_mutex_lock(&mutex)
        array[modIndex] = value
        pthread_mutex_unlock(&mutex)

        return modIndex
    }

    public func get(at index: Int) -> T? {
        return array[index % size]
    }

    public mutating func del(at index: Int) -> T? {

        let modIndex = index % size
        let val = array[modIndex]

        pthread_mutex_lock(&mutex)
        array[modIndex] = nil
        pthread_mutex_unlock(&mutex)

        return val
    }
}
