import SwiftUI

struct StepView: View {
    @State private var stepRecord: [String: Any] = [:]
    private let fetcher = StepDataFetcher()

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            if stepRecord.isEmpty {
                Text("No step data available")
                    .padding()
            } else {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Steps: \(stepRecord["count"] as? Int ?? 0)")
                        .font(.title2)
                    if let start = stepRecord["startDate"] as? String {
                        Text("Start Time: \(start)")
                            .font(.caption)
                            .foregroundColor(.gray)
                    }
                    if let end = stepRecord["endDate"] as? String {
                        Text("End Time: \(end)")
                            .font(.caption)
                            .foregroundColor(.gray)
                    }
                }
                .padding()
            }
        }
        .onAppear {
            fetcher.requestAuthorizationAndFetch { success in
                if success, let data = fetcher.stepData["stepData"] as? [String: Any] {
                    DispatchQueue.main.async {
                        self.stepRecord = data
                    }
                }
            }
        }
        .navigationTitle("Step Count")
    }
}

struct StepView_Previews: PreviewProvider {
    static var previews: some View {
        StepView()
    }
}
