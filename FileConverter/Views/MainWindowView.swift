import SwiftUI

struct MainWindowView: View {
    @StateObject private var jobQueue = JobQueue()
    @State private var selectedConverter: Converter?
    @State private var selectedOptions: [String: String] = [:]
    @State private var converters: [Converter] = []
    @State private var isLoading = true

    var body: some View {
        VStack(spacing: 20) {
            if isLoading {
                ProgressView()
                    .task {
                        do {
                            let loader = ConfigLoader()
                            converters = try await loader.loadDefaultConverters()
                            isLoading = false
                        } catch {
                            isLoading = false
                        }
                    }
            } else {
                DropZoneView(jobQueue: jobQueue, converters: converters, selectedConverter: $selectedConverter, selectedOptions: $selectedOptions)

                if let converter = selectedConverter {
                    ConverterOptionsView(converter: converter, selectedOptions: $selectedOptions)

                    HStack(spacing: 10) {
                        Button("Clear") {
                            jobQueue.jobs.removeAll()
                        }

                        Spacer()

                        Button("Convert") {
                            for var job in jobQueue.jobs.filter({ $0.state == .queued }) {
                                job.converter = converter
                                job.selectedOptions = selectedOptions
                                jobQueue.enqueue(job: job)
                            }
                        }
                        .disabled(jobQueue.jobs.filter({ $0.state == .queued }).isEmpty)
                    }
                    .padding(.horizontal)
                }

                ProgressListView(jobQueue: jobQueue)

                HistoryView(jobQueue: jobQueue)
            }
        }
        .padding()
        .frame(minWidth: 600, minHeight: 500)
    }
}

struct DropZoneView: View {
    @ObservedObject var jobQueue: JobQueue
    let converters: [Converter]
    @Binding var selectedConverter: Converter?
    @Binding var selectedOptions: [String: String]
    @State private var isTargeted = false

    var body: some View {
        VStack(spacing: 20) {
            ZStack {
                RoundedRectangle(cornerRadius: 8)
                    .strokeBorder(isTargeted ? Color.blue : Color.gray, lineWidth: 2)
                    .background(Color(nsColor: .controlBackgroundColor))

                VStack(spacing: 12) {
                    Image(systemName: "arrow.down.doc")
                        .font(.system(size: 48))
                        .foregroundColor(.gray)

                    Text("Drag files here to convert")
                        .font(.headline)

                    Text("or click to browse")
                        .font(.caption)
                        .foregroundColor(.gray)
                }
            }
            .frame(minHeight: 200)
            .onDrop(of: [.fileURL], isTargeted: $isTargeted) { providers in
                for provider in providers {
                    provider.loadFileRepresentation(forTypeIdentifier: "public.file-url") { url, _ in
                        guard let url = url else { return }
                        let job = ConversionJob(id: UUID(), inputURL: url, converter: converters.first ?? Converter(id: "", name: "", category: "", inputFormats: [], outputFormats: [], tool: "", command: "", options: []))
                        jobQueue.enqueue(job: job)
                    }
                }
                return true
            }
        }
    }
}

struct ConverterOptionsView: View {
    let converter: Converter
    @Binding var selectedOptions: [String: String]

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Options")
                .font(.headline)

            ForEach(converter.options) { option in
                OptionControlView(option: option, value: Binding(
                    get: { selectedOptions[option.name] ?? option.default },
                    set: { selectedOptions[option.name] = $0 }
                ))
            }
        }
        .padding()
        .background(Color(nsColor: .controlBackgroundColor))
        .cornerRadius(8)
    }
}

struct OptionControlView: View {
    let option: ConverterOption
    @Binding var value: String

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(option.name)
                .font(.caption)

            switch option.type {
            case .select:
                Picker(option.name, selection: $value) {
                    ForEach(option.values ?? [], id: \.self) { val in
                        Text(val).tag(val)
                    }
                }
                .pickerStyle(.segmented)
            case .slider:
                Slider(value: Binding(
                    get: { Double(value) ?? Double(option.default) ?? 0 },
                    set: { value = String(Int($0)) }
                ), in: Double(option.min ?? 0)...Double(option.max ?? 100))
                    .frame(maxWidth: .infinity)
            }
        }
    }
}

struct ProgressListView: View {
    @ObservedObject var jobQueue: JobQueue

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Progress")
                .font(.headline)

            ScrollView {
                VStack(spacing: 8) {
                    ForEach(jobQueue.jobs) { job in
                        HStack(spacing: 10) {
                            VStack(alignment: .leading, spacing: 4) {
                                Text("\(job.inputURL.lastPathComponent) → \(job.outputURL?.lastPathComponent ?? "...")")
                                    .font(.caption)

                                ProgressView(value: progressValue(job.state))
                                    .tint(progressColor(job.state))
                            }

                            Spacer()

                            stateIcon(job.state)
                        }
                        .padding(8)
                        .background(Color(nsColor: .controlBackgroundColor))
                        .cornerRadius(4)
                    }
                }
            }
        }
    }

    private func progressValue(_ state: ConversionJobState) -> Double {
        switch state {
        case .inProgress(let progress):
            return progress
        case .succeeded:
            return 1.0
        default:
            return 0.0
        }
    }

    private func progressColor(_ state: ConversionJobState) -> Color {
        switch state {
        case .succeeded:
            return .green
        case .failed:
            return .red
        case .inProgress:
            return .blue
        default:
            return .gray
        }
    }

    @ViewBuilder
    private func stateIcon(_ state: ConversionJobState) -> some View {
        switch state {
        case .succeeded:
            Image(systemName: "checkmark.circle.fill")
                .foregroundColor(.green)
        case .failed:
            Image(systemName: "exclamationmark.circle.fill")
                .foregroundColor(.red)
        case .inProgress:
            ProgressView()
        case .cancelled:
            Image(systemName: "xmark.circle.fill")
                .foregroundColor(.gray)
        default:
            EmptyView()
        }
    }
}

struct HistoryView: View {
    @ObservedObject var jobQueue: JobQueue

    var successfulJobs: [ConversionJob] {
        jobQueue.jobs.filter { $0.state == .succeeded }
    }

    var body: some View {
        if !successfulJobs.isEmpty {
            VStack(alignment: .leading, spacing: 10) {
                Text("Recent Conversions")
                    .font(.headline)

                VStack(spacing: 4) {
                    ForEach(successfulJobs.prefix(5)) { job in
                        HStack {
                            Text("\(job.inputURL.lastPathComponent) → \(job.outputURL?.lastPathComponent ?? "")")
                                .font(.caption)
                                .lineLimit(1)
                            Spacer()
                        }
                        .padding(6)
                        .background(Color(nsColor: .controlBackgroundColor))
                        .cornerRadius(4)
                    }
                }
            }
        }
    }
}

#Preview {
    MainWindowView()
}
