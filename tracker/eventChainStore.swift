import Foundation

class EventChainStore: ObservableObject {
    @Published var chains: [EventChain] = []

    func addChain(name: String) {
        let newChain = EventChain(id: UUID(), name: name, events: [])
        chains.append(newChain)
    }

    func addEvent(to chainID: UUID, event: Event) {
        guard let index = chains.firstIndex(where: { $0.id == chainID }) else { return }
        chains[index].events.append(event)
    }
}
