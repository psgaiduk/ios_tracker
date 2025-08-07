import Foundation


struct ChainModel: Identifiable, Codable {
    let id: UUID
    var name: String
    var events: [ChainEventModel]

    var totalDuration: TimeInterval {
        events.reduce(0) { $0 + $1.duration_work + $1.duration_pause }
    }
}
