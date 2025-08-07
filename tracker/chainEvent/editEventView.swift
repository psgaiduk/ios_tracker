import SwiftUI

struct EditEventView: View {
    @State var name: String
    @State var duration: TimeInterval
    @State var pauseAfter: TimeInterval

    var originalEvent: Event
    var onSave: (Event) -> Void

    @Environment(\.dismiss) var dismiss

    init(event: Event, onSave: @escaping (Event) -> Void) {
        self.originalEvent = event
        self._name = State(initialValue: event.name)
        self._duration = State(initialValue: event.duration)
        self._pauseAfter = State(initialValue: event.pauseAfter)
        self.onSave = onSave
    }

    var body: some View {
        NavigationView {
            Form {
                TextField("Название", text: $name)
                Stepper("Длительность: \(Int(duration)) сек", value: $duration, in: 10...3600, step: 10)
                Stepper("Пауза после: \(Int(pauseAfter)) сек", value: $pauseAfter, in: 0...600, step: 5)
            }
            .navigationTitle("Редактировать событие")
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Сохранить") {
                        let updated = Event(id: originalEvent.id, name: name, duration: duration, pauseAfter: pauseAfter)
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
