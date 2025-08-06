import Foundation

func formatDuration(_ seconds: TimeInterval) -> String {
    let minutes = Int(seconds) / 60
    let secs = Int(seconds) % 60
    return "\(minutes)m \(secs)s"
}
