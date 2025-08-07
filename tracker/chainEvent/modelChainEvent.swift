import Foundation

struct ChainEventModel: Identifiable, Codable {
    let id: UUID
    var name: String
    var duration_work: TimeInterval // в секундах
    var pauseAfter: TimeInterval // пауза после
}
