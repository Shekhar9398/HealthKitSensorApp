import SwiftUI

struct RespirationRateView: View {
    @State private var records: [[String: Any]] = []
    private let fetcher = RespirationRateDataFetcher()

    var body: some View {
        VStack(alignment: .leading) {
            if records.isEmpty {
                Text("No respiration rate data available")
                    .padding()
            } else {
                List {
                    ForEach(records.indices, id: \.self) { index in
                        let record = records[index]
                        VStack(alignment: .leading, spacing: 5) {
                            Text("Respiratory Rate: \(record["respiratoryRate"] as? Double ?? 0) breaths/min")
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
                if success, let respirationRateData = fetcher.respirationRateData["respirationRateData"] as? [[String: Any]] {
                    DispatchQueue.main.async {
                        self.records = respirationRateData
                    }
                }
            }
        }
        .navigationTitle("Respiratory Rate")
    }
}

struct RespirationRateView_Previews: PreviewProvider {
    static var previews: some View {
        RespirationRateView()
    }
}
