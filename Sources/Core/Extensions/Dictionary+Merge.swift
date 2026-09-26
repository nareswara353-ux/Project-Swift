import Foundation

public extension Dictionary {
    func merging(_ other: [Key: Value]) -> [Key: Value] {
        var copy = self
        for (k, v) in other { copy[k] = v }
        return copy
    }
}
