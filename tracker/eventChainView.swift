import SwiftUI

struct EventChainView: View {
    @Environment(\.dismiss) var dismiss
    @State var chain: EventChain
    @ObservedObject var store: EventChainStore
    
    @State private var showRunView = false
    @State private var showingAddEvent = false
    @State private var showingEditChainName = false
    @State private var editingEvent: Event?

    var body: some View {
        List {
            Section(header: Text("События")) {
                ForEach(chain.events) { event in
                    Button {
                        editingEvent = event
                    } label: {
                        VStack(alignment: .leading) {
                            Text(event.name).font(.headline)
                            Text("Длительность: \(formatDuration(event.duration)), пауза: \(formatDuration(event.pauseAfter))")
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
    let testStore = EventChainStore()
    let exampleEvents = [
        Event(id: UUID(), name: "Разминка", duration: 60, pauseAfter: 10),
        Event(id: UUID(), name: "Бег", duration: 120, pauseAfter: 20),
        Event(id: UUID(), name: "Отдых", duration: 90, pauseAfter: 0)
    ]

    let exampleChain = EventChain(id: UUID(), name: "Утренние упражнения", events: exampleEvents)

    return EventChainView(chain: exampleChain, store: testStore)
}
