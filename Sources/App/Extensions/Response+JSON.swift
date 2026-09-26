import Vapor

extension Response {
    static func json<T: Content>(_ value: T, status: HTTPStatus = .ok, for req: Request) throws -> Response {
        let response = Response(status: status)
        try response.content.encode(value, as: .json)
        return response
    }
}
