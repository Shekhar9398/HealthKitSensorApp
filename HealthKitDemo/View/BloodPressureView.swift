import SwiftUI

struct BloodPressureView: View {
    @State private var records: [[String: Any]] = []
    private let fetcher = BloodPressureDataFetcher.shared

    var body: some View {
        VStack(alignment: .leading) {
            if records.isEmpty {
                Text("No blood pressure data available")
                    .padding()
            } else {
                List {
                    ForEach(records.indices, id: \.self) { index in
                        let record = records[index]
                        VStack(alignment: .leading, spacing: 5) {
                            Text("Systolic: \(record["systolic"] as? Double ?? 0) mmHg")
                            Text("Diastolic: \(record["diastolic"] as? Double ?? 0) mmHg")
                            if let date = record["startDate"] as? Date {
                                Text("Time: \(date.formatted(.dateTime.hour().minute()))")
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
            fetcher.requestAuthorizationAndFetch()
            fetcher.fetchAllBloodPressureRecords { data in
                if let rawRecords = data?["records"] as? [[String: Any]] {
                    DispatchQueue.main.async {
                        self.records = rawRecords
                    }
                }
            }
        }
        .navigationTitle("Blood Pressure")
    }
}
