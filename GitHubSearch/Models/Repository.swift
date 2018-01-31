import Foundation

struct Repository: Decodable {
    let id: Int
    let fullName: String
    let htmlURL: URL

    enum CodingKeys: String, CodingKey {
        case id
        case fullName = "full_name"
        case htmlURL = "html_url"
    }
}

extension Repository: Equatable {
    static func == (lhs: Repository, rhs: Repository) -> Bool {
        return lhs.id == rhs.id
    }
}
