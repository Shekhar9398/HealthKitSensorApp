import SwiftUI

struct SleepDataView: View {
    @State private var records: [[String: Any]] = []
    private let fetcher = SleepDataFetcher()
    
    var body: some View {
        VStack(alignment: .leading) {
            if records.isEmpty {
                Text("No sleep data available")
                    .padding()
            } else {
                List {
                    ForEach(records.indices, id: \.self) { index in
                        let record = records[index]
                        VStack(alignment: .leading, spacing: 5) {
                            if let category = record["category"] as? String {
                                Text("Category: \(category)")
                            }
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
                            if let duration = record["durationMinutes"] as? Double {
                                Text("Duration: \(duration, specifier: "%.2f") minutes")
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
                if success, let sleepData = fetcher.sleepData["sleepData"] as? [[String: Any]] {
                    DispatchQueue.main.async {
                        self.records = sleepData
                    }
                }
            }
        }
        .navigationTitle("Sleep Data")
    }
}

struct SleepDataView_Previews: PreviewProvider {
    static var previews: some View {
        SleepDataView()
    }
}
