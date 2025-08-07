import Foundation

struct ChainEventModel: Identifiable, Codable {
    let id: UUID
    var name: String
    var duration_work: TimeInterval
    var duration_pause: TimeInterval
}
