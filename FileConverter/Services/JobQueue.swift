import Foundation
import Combine

@MainActor
class JobQueue: ObservableObject {
    @Published var jobs: [ConversionJob] = []
    @Published var isProcessing = false

    private let converterEngine = ConverterEngine()
    private var processingTask: Task<Void, Never>?

    func enqueue(job: ConversionJob) {
        jobs.append(job)
        startProcessing()
    }

    func cancel(jobId: UUID) {
        if let index = jobs.firstIndex(where: { $0.id == jobId }) {
            jobs[index].state = .cancelled
        }
    }

    func getJob(id: UUID) -> ConversionJob? {
        jobs.first(where: { $0.id == id })
    }

    private func startProcessing() {
        guard !isProcessing else { return }
        guard !jobs.isEmpty else { return }

        isProcessing = true

        processingTask = Task {
            while !jobs.isEmpty {
                if let queuedIndex = jobs.firstIndex(where: { $0.state == .queued }) {
                    var job = jobs[queuedIndex]

                    do {
                        try await converterEngine.convert(job: &job) { progress in
                            Task { @MainActor in
                                self.jobs[queuedIndex].state = .inProgress(progress: progress)
                            }
                        }
                        jobs[queuedIndex] = job
                    } catch {
                        jobs[queuedIndex].state = .failed(error: error.localizedDescription)
                    }
                } else {
                    break
                }
            }

            isProcessing = false
        }
    }
}
