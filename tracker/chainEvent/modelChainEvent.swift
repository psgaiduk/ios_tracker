import Foundation

struct Event: Identifiable, Codable {
    let id: UUID
    var name: String
    var duration: TimeInterval // в секундах
    var pauseAfter: TimeInterval // пауза после
}
