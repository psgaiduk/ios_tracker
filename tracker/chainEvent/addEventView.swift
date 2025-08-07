import SwiftUI

struct AddEventView: View {
    @Environment(\.dismiss) var dismiss
    var chainID: UUID
    @ObservedObject var store: ChainStore

    @State private var name = ""
    @State private var duration: Double = 60
    @State private var pause: Double = 10

    var body: some View {
        NavigationView {
            Form {
                TextField("Название события", text: $name)
                Stepper("Длительность: \(Int(duration)) сек", value: $duration, in: 10...3600, step: 10)
                Stepper("Пауза после: \(Int(pause)) сек", value: $pause, in: 0...600, step: 5)
            }
            .navigationTitle("Новое событие")
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Сохранить") {
                        let newEvent = Event(id: UUID(), name: name, duration: duration, pauseAfter: pause)
                        store.addEvent(to: chainID, event: newEvent)
                        dismiss()
                    }
                }
                ToolbarItem(placement: .cancellationAction) {
                    Button("Отмена") {
                        dismiss()
                    }
                }
            }
        }
    }
}
