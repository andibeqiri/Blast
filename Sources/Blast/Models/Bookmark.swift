import Foundation

struct Bookmark: Identifiable {
    let id = UUID()
    let title: String
    let url: String
    let icon: String
}
