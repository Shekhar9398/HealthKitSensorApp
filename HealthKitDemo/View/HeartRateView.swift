import SwiftUI

struct HeartRateView: View {
    @State private var records: [[String: Any]] = []
    private let fetcher = HeartRateDataFetcher()

    var body: some View {
        VStack(alignment: .leading) {
            if records.isEmpty {
                Text("No heart rate data available")
                    .padding()
            } else {
                List {
                    ForEach(records.indices, id: \.self) { index in
                        let record = records[index]
                        VStack(alignment: .leading, spacing: 5) {
                            Text("Heart Rate: \(record["bpm"] as? Double ?? 0) bpm")
                            if let startDate = record["startDate"] as? String {
                                Text("Start Time: \(startDate)")
                                    .font(.caption)
                                    .foregroundColor(.gray)
                            }
                            if let endDate = record["endDate"] as? String {
                                Text("End Time: \(endDate)")
                                    .font(.caption)
                                    .foregroundColor(.gray)
                            }
                        }
                        .padding(.vertical, 4)
                    }
                }
            }
        }
        .onAppear {
            fetcher.requestAuthorizationAndFetch { success in
                if success, let heartRateData = fetcher.heartRateData["heartRateData"] as? [[String: Any]] {
                    DispatchQueue.main.async {
                        self.records = heartRateData
                    }
                }
            }
        }
        .navigationTitle("Heart Rate")
    }
}

struct HeartRateView_Previews: PreviewProvider {
    static var previews: some View {
        HeartRateView()
    }
}
