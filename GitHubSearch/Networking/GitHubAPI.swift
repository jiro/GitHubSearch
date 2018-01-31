import Moya

let GitHubProvider = MoyaProvider<GitHub>(plugins: [GitHubAuthPlugin(token: Const.accessToken)])

enum GitHub {
    case searchRepositories(String, Int)
}

extension GitHub: TargetType {
    var baseURL: URL {
        return URL(string: "https://api.github.com")!
    }

    var path: String {
        switch self {
        case .searchRepositories:
            return "/search/repositories"
        }
    }

    var method: Moya.Method {
        return .get
    }

    var task: Task {
        switch self {
        case let .searchRepositories(query, page):
            return .requestParameters(parameters: ["q": query, "page": page], encoding: URLEncoding.default)
        }
    }

    var validate: Bool {
        return false
    }

    var sampleData: Data {
        return "".data(using: .utf8)!
    }

    var headers: [String: String]? {
        return nil
    }
}
