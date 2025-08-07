import SwiftUI

struct ChainView: View {
    @Environment(\.dismiss) var dismiss
    @State var chain: ChainModel
    @ObservedObject var store: ChainStore
    
    @State private var showRunView = false
    @State private var showingAddEvent = false
    @State private var showingEditChainName = false
    @State private var editingEvent: ChainEventModel?

    var body: some View {
        List {
            Section(header: Text("События")) {
                ForEach(chain.events) { event in
                    Button {
                        editingEvent = event
                    } label: {
                        VStack(alignment: .leading) {
                            Text(event.name).font(.headline)
                            Text("Длительность: \(formatDuration(event.duration_work)), пауза: \(formatDuration(event.duration_pause))")
                                .font(.subheadline)
                        }
                    }
                }
                .onDelete(perform: deleteEvent)
            }
            
            Button(action: {
                showRunView = true
            }) {
                Text("Старт")
                    .font(.headline)
                    .foregroundColor(.blue)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.blue.opacity(0.1))
                    .cornerRadius(10)
                    .padding(.horizontal)
            }

        }
        .navigationTitle(chain.name)
        .toolbar {
            Button("Редактировать") {
                showingEditChainName = true
            }
            Button(action: {
                showingAddEvent = true
            }) {
                Image(systemName: "plus")
            }
        }
        .sheet(isPresented: $showingAddEvent) {
            AddEventView(chainID: chain.id, store: store)
        }
        .sheet(item: $editingEvent) { event in
            EditEventView(event: event) { updatedEvent in
                if let index = chain.events.firstIndex(where: { $0.id == updatedEvent.id }) {
                    chain.events[index] = updatedEvent
                    updateStore()
                }
            }
        }
        .fullScreenCover(isPresented: $showRunView) {
            RunEventChainView(chain: chain)
        }
        .alert("Изменить название цепочки", isPresented: $showingEditChainName) {
            TextField("Название", text: Binding(
                get: { chain.name },
                set: { newValue in
                    chain.name = newValue
                    updateStore()
                }
            ))
            Button("Готово", role: .cancel) {}
        }
    }

    func deleteEvent(at offsets: IndexSet) {
        chain.events.remove(atOffsets: offsets)
        updateStore()
    }

    func updateStore() {
        if let index = store.chains.firstIndex(where: { $0.id == chain.id }) {
            store.chains[index] = chain
        }
    }
}


#Preview {
    let testStore = ChainStore()
    let exampleEvents = [
        ChainEventModel(id: UUID(), name: "Разминка", duration_work: 60, duration_pause: 10),
        ChainEventModel(id: UUID(), name: "Бег", duration_work: 120, duration_pause: 20),
        ChainEventModel(id: UUID(), name: "Отдых", duration_work: 90, duration_pause: 0)
    ]

    let exampleChain = ChainModel(id: UUID(), name: "Утренние упражнения", events: exampleEvents)

    return ChainView(chain: exampleChain, store: testStore)
}
