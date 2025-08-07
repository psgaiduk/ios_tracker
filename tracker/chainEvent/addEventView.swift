import SwiftUI

struct AddEventView: View {
    @Environment(\.dismiss) var dismiss
    var chainID: UUID
    @ObservedObject var store: ChainStore

    @State private var name = ""
    @State private var duration_work: Double = 60
    @State private var duration_pause: Double = 10

    var body: some View {
        NavigationView {
            Form {
                TextField("Название события", text: $name)
                Stepper("Длительность: \(Int(duration_work)) сек", value: $duration_work, in: 10...3600, step: 10)
                Stepper("Пауза после: \(Int(duration_pause)) сек", value: $duration_pause, in: 0...600, step: 5)
            }
            .navigationTitle("Новое событие")
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Сохранить") {
                        let newEvent = ChainEventModel(id: UUID(), name: name, duration_work: duration_work, duration_pause: duration_pause)
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
