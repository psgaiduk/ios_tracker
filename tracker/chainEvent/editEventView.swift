import SwiftUI

struct EditEventView: View {
    @State var name: String
    @State var duration_work: TimeInterval
    @State var pauseAfter: TimeInterval

    var originalEvent: ChainEventModel
    var onSave: (ChainEventModel) -> Void

    @Environment(\.dismiss) var dismiss

    init(event: ChainEventModel, onSave: @escaping (ChainEventModel) -> Void) {
        self.originalEvent = event
        self._name = State(initialValue: event.name)
        self._duration_work = State(initialValue: event.duration_work)
        self._pauseAfter = State(initialValue: event.pauseAfter)
        self.onSave = onSave
    }

    var body: some View {
        NavigationView {
            Form {
                TextField("Название", text: $name)
                Stepper("Длительность: \(Int(duration_work)) сек", value: $duration_work, in: 10...3600, step: 10)
                Stepper("Пауза после: \(Int(pauseAfter)) сек", value: $pauseAfter, in: 0...600, step: 5)
            }
            .navigationTitle("Редактировать событие")
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Сохранить") {
                        let updated = ChainEventModel(id: originalEvent.id, name: name, duration_work: duration_work, pauseAfter: pauseAfter)
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
