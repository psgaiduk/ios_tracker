import SwiftUI
import AVFoundation // для AVAudioPlayer

struct RunEventChainView: View {
    let chain: EventChain
    @Environment(\.dismiss) var dismiss

    @State private var currentIndex = 0
    @State private var timeRemaining: TimeInterval = 0
    @State private var isPaused = false
    @State private var isRunning = false
    @State private var isFinished = false
    @State private var phase: Phase = .event

    enum Phase {
        case event
        case pause
    }

    let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()

    // AVAudioPlayer для звука (если нужен кастомный звук)
    @State private var player: AVAudioPlayer?

    var body: some View {
        GeometryReader { geo in
            ZStack {
                (phase == .event ? Color.blue.opacity(0.3) : Color.yellow.opacity(0.3))
                    .ignoresSafeArea()
                    .animation(.easeInOut, value: phase)

                if isFinished {
                    VStack {
                        Spacer()
                        Text("✅ Все события завершены")
                            .font(.largeTitle)
                            .bold()
                            .multilineTextAlignment(.center)
                        Spacer()
                    }
                    .onAppear {
                        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                            dismiss()
                        }
                    }
                } else {
                    VStack(spacing: 25) {
                        Text("Событие \(currentIndex + 1) из \(chain.events.count)")
                            .font(.headline)
                        
                        Text(currentEventText())
                            .font(.title)
                            .multilineTextAlignment(.center)
                        
                        GeometryReader { geo in
                            ZStack {
                                Circle()
                                    .stroke(Color.gray.opacity(0.3), lineWidth: 20)
                                
                                Circle()
                                    .trim(from: 0, to: progress())
                                    .stroke(phase == .event ? Color.blue : Color.orange, style: StrokeStyle(lineWidth: 20, lineCap: .round))
                                    .rotationEffect(.degrees(-90))
                                    .animation(.linear(duration: 1), value: timeRemaining)
                                
                                Text(formattedTime(Int(timeRemaining)))
                                    .font(.system(size: min(geo.size.width, geo.size.height) / 4, weight: .bold))
                                
                            }
                            .frame(width: geo.size.width, height: geo.size.height)
                        }
                        .frame(height: UIScreen.main.bounds.height / 2)
                        
                        if !isRunning {
                            Button(action: start) {
                                Text("▶ Старт")
                                    .font(.title)
                                    .foregroundColor(.white)
                                    .frame(width: 180, height: 60)
                                    .background(Color.blue)
                                    .cornerRadius(15)
                                    .shadow(radius: 5)
                            }
                        } else {
                            HStack(spacing: 10) {
                                if currentIndex > 0 {
                                    Button(action: {
                                        currentIndex -= 1
                                        phase = .event
                                        resetTimer()
                                        isPaused = false
                                    }) {
                                        Text("Назад")
                                            .font(.headline)
                                            .foregroundColor(.white)
                                            .frame(width: 90, height: 50)
                                            .background(Color.gray)
                                            .cornerRadius(12)
                                            .shadow(radius: 4)
                                    }
                                }
                                
                                Button(action: { isPaused.toggle() }) {
                                    Text(isPaused ? "Продолжить" : "Пауза")
                                        .font(.headline)
                                        .foregroundColor(.white)
                                        .frame(width: 90, height: 50)
                                        .background(isPaused ? Color.gray : Color.gray)
                                        .cornerRadius(12)
                                        .shadow(radius: 4)
                                }
                                
                                Button(action: moveToNextEvent) {
                                    Text("Далее")
                                        .font(.headline)
                                        .foregroundColor(.white)
                                        .frame(width: 90, height: 50)
                                        .background(Color.gray)
                                        .cornerRadius(12)
                                        .shadow(radius: 4)
                                }
                            }
                            .frame(maxWidth: .infinity)
                            .padding(.horizontal, 20)
                            .contentShape(Rectangle()) // чтобы отступы были кликабельными, если нужно
//                            .alignmentGuide(.center) { _ in 0 } // по центру в родительском VStack

                        }
                                                
                        if let nextEvent = (currentIndex + 1 < chain.events.count) ? chain.events[currentIndex + 1] : nil {
                            if !nextEvent.name.isEmpty {
                                Text("Следующий этап: \(nextEvent.name)")
                                    .font(.headline)
                            }
                        }
                        
                        Button(action: { dismiss() }) {
                            Text("Завершить")
                                .font(.headline)
                                .foregroundColor(.white)
                                .frame(width: 180, height: 50)
                                .background(Color.red)
                                .cornerRadius(15)
                                .shadow(radius: 4)
                        }
                    }
                    .padding()
                }
            }
        }
        .onReceive(timer) { _ in
            guard isRunning, !isPaused, !isFinished else { return }
            if timeRemaining > 0 {
                timeRemaining -= 1
            } else {
                playSound()
                nextStep()
            }
        }
        .onAppear {
            resetTimer()
            prepareSound()
        }
    }

    private func currentEventText() -> String {
        let event = chain.events[currentIndex]
        switch phase {
        case .event:
            return event.name
        case .pause:
            return "Пауза"
        }
    }

    private func progress() -> CGFloat {
        let event = chain.events[currentIndex]
        let total = phase == .event ? event.duration : event.pauseAfter
        if total == 0 { return 1 }
        return CGFloat(total - timeRemaining) / CGFloat(total)
    }

    private func start() {
        isRunning = true
        isPaused = false
        resetTimer()
    }

    private func resetTimer() {
        let event = chain.events[currentIndex]
        timeRemaining = (phase == .event) ? event.duration : event.pauseAfter
    }

    private func moveToNextEvent() {
        playSound()
        nextStep()
    }

    private func nextStep() {
        let event = chain.events[currentIndex]

        switch phase {
        case .event:
            if event.pauseAfter > 0 {
                phase = .pause
                resetTimer()
            } else {
                advanceToNext()
            }
        case .pause:
            advanceToNext()
        }
    }

    private func advanceToNext() {
        if currentIndex + 1 < chain.events.count {
            currentIndex += 1
            phase = .event
            resetTimer()
        } else {
            isFinished = true
            isRunning = false
        }
    }

    private func prepareSound() {
        // Если хочешь проигрывать кастомный звук из файла, раскомментируй и добавь файл в проект
        /*
        guard let url = Bundle.main.url(forResource: "soundName", withExtension: "mp3") else { return }
        player = try? AVAudioPlayer(contentsOf: url)
        player?.prepareToPlay()
        */
    }

    private func playSound() {
        // Если хочешь системный звук, вызови так:
        AudioServicesPlaySystemSound(1001)

        // Или, если используешь player, то:
        // player?.stop()
        // player?.currentTime = 0
        // player?.play()
    }
    
    private func formattedTime(_ seconds: Int) -> String {
        if seconds >= 3600 {
            let hours = seconds / 3600
            let minutes = (seconds % 3600) / 60
            return String(format: "%02d:%02d", hours, minutes)
        } else {
            let minutes = seconds / 60
            let secs = seconds % 60
            return String(format: "%02d:%02d", minutes, secs)
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

