import Foundation

public extension Encodable {
    func toJSONData(encoder: JSONEncoder = JSONEncoder()) throws -> Data {
        try encoder.encode(self)
    }
    
    func toJSONString(encoder: JSONEncoder = JSONEncoder()) throws -> String {
        let data = try toJSONData(encoder: encoder)
        return String(data: data, encoding: .utf8) ?? ""
    }
}
