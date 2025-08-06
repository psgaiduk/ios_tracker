import Foundation

struct Event: Identifiable, Codable {
    let id: UUID
    var name: String
    var duration: TimeInterval // в секундах
    var pauseAfter: TimeInterval // пауза после
}

struct EventChain: Identifiable, Codable {
    let id: UUID
    var name: String
    var events: [Event]

    var totalDuration: TimeInterval {
        events.reduce(0) { $0 + $1.duration + $1.pauseAfter }
    }
}
