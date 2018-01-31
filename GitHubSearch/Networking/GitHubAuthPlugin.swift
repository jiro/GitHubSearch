import Foundation
import Moya

struct GitHubAuthPlugin: PluginType {

    private let token: String

    init(token: String) {
        self.token = token
    }

    func prepare(_ request: URLRequest, target: TargetType) -> URLRequest {
        guard !token.isEmpty else {
            return request
        }
        var request = request
        request.addValue("token " + token, forHTTPHeaderField: "Authorization")
        return request
    }
}
