import SwiftUI

struct AddChainView: View {
    @Environment(\.dismiss) var dismiss
    @ObservedObject var store: EventChainStore
    @State private var name = ""

    var body: some View {
        NavigationView {
            Form {
                TextField("Название цепочки", text: $name)
            }
            .navigationTitle("Новая цепочка")
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Сохранить") {
                        store.addChain(name: name)
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
