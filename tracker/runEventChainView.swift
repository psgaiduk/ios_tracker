import SwiftUI

struct RunEventChainView: View {
    let chain: EventChain
    @Environment(\.dismiss) var dismiss

    @State private var currentIndex = 0
    @State private var timeRemaining: Int = 0
    @State private var isPaused = false
    @State private var isRunning = false
    @State private var isFinished = false

    @State private var phase: Phase = .event

    enum Phase {
        case event
        case pause
    }

    let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    var body: some View {
        ZStack {
            if isFinished {
                VStack {
                    Spacer()
                    Text("✅ Все события завершены")
                        .font(.largeTitle)
                        .bold()
                        .multilineTextAlignment(.center)
                    Spacer()
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(Color.white)
                .onAppear {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                        dismiss()
                    }
                }
            } else {
                VStack(spacing: 30) {
                    VStack(spacing: 60) {
                        Text("Событие \(currentIndex + 1) из \(chain.events.count)")
                            .font(.headline)
                        
                        Text(currentEventText())
                            .font(.title)
                            .multilineTextAlignment(.center)
                        
                        Text("Осталось: \(timeRemaining) сек")
                            .font(.system(size: 32, weight: .bold))
                        
                        if isRunning {
                            Button("⏸ Пауза") {
                                isPaused.toggle()
                            }
                        } else {
                            Button("▶ Старт") {
                                start()
                            }
                        }
                        
                        if isRunning && !isPaused {
                            Button("⏭ Пропустить") {
                                moveToNextEvent()
                            }
                            .foregroundColor(.red)
                        }
                        
                        if isPaused {
                            Button("⏭ Пропустить") {
                                moveToNextEvent()
                            }
                            .foregroundColor(.red)
                            Text("⏸ Приостановлено")
                        }
                    }
                    Spacer()  // Выталкиваем кнопку вниз
                    
                    Button("⏹ Завершить") {
                        dismiss()
                    }
                    .padding()
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)  // чтобы занять весь экран
                .padding()
            }
        }
        .onReceive(timer) { _ in
            guard isRunning, !isPaused, !isFinished else { return }
            if timeRemaining > 0 {
                timeRemaining -= 1
            } else {
                nextStep()
            }
        }
    }


    private func start() {
        isRunning = true
        currentIndex = 0
        phase = .event
        timeRemaining = Int(chain.events.first?.duration ?? 0)
    }

    private func nextStep() {
        let current = chain.events[currentIndex]

        switch phase {
        case .event:
            if current.pauseAfter > 0 {
                phase = .pause
                timeRemaining = Int(current.pauseAfter)
            } else {
                moveToNextEvent()
            }
        case .pause:
            moveToNextEvent()
        }
    }

    private func moveToNextEvent() {
        currentIndex += 1
        if currentIndex >= chain.events.count {
            isFinished = true
            isRunning = false
        } else {
            phase = .event
            timeRemaining = Int(chain.events[currentIndex].duration)
        }
    }

    private func currentEventText() -> String {
        if currentIndex >= chain.events.count {
            return "Готово!"
        }

        let event = chain.events[currentIndex]
        switch phase {
        case .event:
            return "🔵 \(event.name)"
        case .pause:
            return "⏳ Пауза после: \(event.name)"
        }
    }
}


#Preview {
    let exampleEvents = [
        Event(id: UUID(), name: "Разминка", duration: 60, pauseAfter: 10),
        Event(id: UUID(), name: "Бег", duration: 120, pauseAfter: 20),
        Event(id: UUID(), name: "Отдых", duration: 90, pauseAfter: 0)
    ]

    let exampleChain = EventChain(id: UUID(), name: "Утренние упражнения", events: exampleEvents)

    return RunEventChainView(chain: exampleChain)
}
