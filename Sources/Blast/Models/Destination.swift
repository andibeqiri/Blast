import Foundation

enum Destination: Identifiable, Equatable {
    case page(title: String, url: String, icon: String)
    case search(engine: String, query: String, url: String)
    case answer(query: String, text: String)

    var id: String {
        switch self {
        case .page(_, let url, _): return "page:\(url)"
        case .search(let engine, let query, _): return "search:\(engine):\(query)"
        case .answer(let query, _): return "answer:\(query)"
        }
    }
}
