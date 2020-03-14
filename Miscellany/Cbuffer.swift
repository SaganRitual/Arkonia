class Cbuffer<T> {
    var cElements: Int
    var elements: [T]
    var firstPass = true
    var nextPopOffset: Int = 0
    var nextPushOffset: Int = 0
    var wrappedPop = false

    var count: Int {
        if nextPushOffset == nextPopOffset {
            Debug.log(level: 129) { "count.1 \(nextPushOffset) == \(nextPopOffset) -> \(wrappedPop) ? \(cElements) : 0" }
            return wrappedPop ? cElements : 0 }
        if nextPushOffset > nextPopOffset  {
            Debug.log(level: 129) { " count.2 \(nextPushOffset) > \(nextPopOffset) -> \(nextPushOffset - nextPopOffset)" }
            return nextPushOffset - nextPopOffset }
        else                               {
            Debug.log(level: 129) { " count.3 \(nextPushOffset) < \(nextPopOffset) -> \(nextPushOffset - nextPopOffset + cElements)" }
            return nextPushOffset - nextPopOffset + cElements }
    }

    // swiftlint:disable empty_count
    var isEmpty: Bool { count == 0 }
    // swiftlint:enable empty_count

    init(cElements: Int) {
        self.cElements = cElements

        elements = []
        elements.reserveCapacity(cElements)
    }

    func pop() -> T {
        assert(nextPopOffset != nextPushOffset || wrappedPop == true)

        defer {
            nextPopOffset = (nextPopOffset + 1) % cElements
            wrappedPop = false
        }

        return elements[nextPopOffset]
    }

    func push(_ element: T) {
        assert(nextPopOffset != nextPushOffset || wrappedPop == false)

        defer {
            nextPushOffset = (nextPushOffset + 1) % cElements

            // Rememeber that the push pointer has caught the pop pointer,
            // meaning that we've wrapped all the way around to it
            wrappedPop = (nextPushOffset == nextPopOffset)
            firstPass = false
        }

        if elements.count < cElements {
            elements.append(element)
            return
        }

        elements[nextPushOffset] = element
    }
}
