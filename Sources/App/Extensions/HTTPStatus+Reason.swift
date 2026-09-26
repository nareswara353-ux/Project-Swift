import Vapor

extension HTTPStatus {
    var reasonText: String {
        self.reasonPhrase
    }
}
