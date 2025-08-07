import SwiftUI

struct EditEventView: View {
    @State var name: String
    @State var duration_work: TimeInterval
    @State var duration_pause: TimeInterval

    var originalEvent: ChainEventModel
    var onSave: (ChainEventModel) -> Void

    @Environment(\.dismiss) var dismiss

    init(event: ChainEventModel, onSave: @escaping (ChainEventModel) -> Void) {
        self.originalEvent = event
        self._name = State(initialValue: event.name)
        self._duration_work = State(initialValue: event.duration_work)
        self._duration_pause = State(initialValue: event.duration_pause)
        self.onSave = onSave
    }

    var body: some View {
        NavigationView {
            Form {
                TextField("Название", text: $name)
                Stepper("Длительность: \(Int(duration_work)) сек", value: $duration_work, in: 10...3600, step: 10)
                Stepper("Пауза после: \(Int(duration_pause)) сек", value: $duration_pause, in: 0...600, step: 5)
            }
            .navigationTitle("Редактировать событие")
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Сохранить") {
                        let updated = ChainEventModel(id: originalEvent.id, name: name, duration_work: duration_work, duration_pause: duration_pause)
                        onSave(updated)
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
