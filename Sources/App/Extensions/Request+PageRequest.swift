import Vapor
import Domain

extension Request {
    var pageRequest: PageRequest {
        let page = (try? query.get(Int.self, at: "page")) ?? 1
        let perPage = (try? query.get(Int.self, at: "perPage")) ?? PageRequest.default.perPage
        return PageRequest(page: page, perPage: perPage) ?? .default
    }
}
