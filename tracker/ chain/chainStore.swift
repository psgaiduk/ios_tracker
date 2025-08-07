import Foundation

class ChainStore: ObservableObject {
    @Published var chains: [ChainModel] = []

    func addChain(name: String) {
        let newChain = ChainModel(id: UUID(), name: name, events: [])
        chains.append(newChain)
    }

    func addEvent(to chainID: UUID, event: ChainEventModel) {
        guard let index = chains.firstIndex(where: { $0.id == chainID }) else { return }
        chains[index].events.append(event)
    }
}
