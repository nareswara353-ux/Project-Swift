import Foundation

public extension Int {
    var isPositive: Bool { self > 0 }
    var isNonNegative: Bool { self >= 0 }
    
    func clamped(to range: ClosedRange<Int>) -> Int {
        Swift.min(Swift.max(self, range.lowerBound), range.upperBound)
    }
}
