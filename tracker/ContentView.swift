import SwiftUI

struct ContentView: View {
    @StateObject var store: EventChainStore

    @State private var showingAddChain = false
    @State private var runningChain: ChainModel?
    @State private var editingChain: ChainModel?

    var body: some View {
        NavigationStack {
            List {
                ForEach(store.chains) { chain in
                    HStack {
                        Button(action: {
                            runningChain = chain
                        }) {
                            Image(systemName: "play.fill")
                                .foregroundColor(.blue)
                        }
                        .buttonStyle(BorderlessButtonStyle())
                        .padding(.trailing, 10)
                        .frame(width: 32, height: 32, alignment: .center)
                        .contentShape(Rectangle())
                        
                        Button(action: {
                            runningChain = chain
                        }) {
                            VStack(alignment: .leading) {
                                Text(chain.name).font(.headline)
                                HStack{
                                    Text("Событий: \(chain.events.count)")
                                        .font(.subheadline)
                                    Text("Длительность: \(formatDuration(chain.totalDuration))")
                                        .font(.subheadline)
                                }
                            }
                            .frame(maxWidth: .infinity, alignment: .leading)
                        }
                        .buttonStyle(PlainButtonStyle())

                        NavigationLink(destination: ChainView(chain: chain, store: store)) {
                            Image(systemName: "pencil")
                                .foregroundColor(.blue)
                                .frame(width: 24, height: 24)
                        }
                        .buttonStyle(PlainButtonStyle())
                        .frame(width: 32, height: 32, alignment: .center)
                    }
                }
            }
            .navigationTitle("Цепочки событий")
            .toolbar {
                Button(action: {
                    showingAddChain = true
                }) {
                    Image(systemName: "plus")
                }
            }
            .sheet(isPresented: $showingAddChain) {
                AddChainView(store: store)
            }
            .fullScreenCover(item: $runningChain) { chain in
                RunEventChainView(chain: chain)
            }
            .fullScreenCover(item: $editingChain) { chain in
                ChainView(chain: chain, store: store)
            }
        }
    }
}



#Preview {
    let testStore = EventChainStore()
    testStore.chains = [
        ChainModel(
            id: UUID(),
            name: "Утренняя тренировка",
            events: [
                Event(id: UUID(), name: "Разминка", duration: 5, pauseAfter: 3),
                Event(id: UUID(), name: "Бег", duration: 5, pauseAfter: 3),
                Event(id: UUID(), name: "Растяжка", duration: 5, pauseAfter: 2)
            ]
        )
    ]
    return ContentView(store: testStore)
}
