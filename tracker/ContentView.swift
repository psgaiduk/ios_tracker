import SwiftUI

struct ContentView: View {
    @StateObject var store: ChainStore

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
    let testStore = ChainStore()
    testStore.chains = [
        ChainModel(
            id: UUID(),
            name: "Утренняя тренировка",
            events: [
                ChainEventModel(id: UUID(), name: "Разминка", duration_work: 5, duration_pause: 3),
                ChainEventModel(id: UUID(), name: "Бег", duration_work: 5, duration_pause: 3),
                ChainEventModel(id: UUID(), name: "Растяжка", duration_work: 5, duration_pause: 2)
            ]
        )
    ]
    return ContentView(store: testStore)
}
