import SwiftUI

struct BloodOxygenView: View {
    @ObservedObject var fetcher = BloodOxygenDataFetcher.shared

    var body: some View {
        VStack(alignment: .leading) {
            if fetcher.bloodOxygenRecords.isEmpty {
                Text("No blood oxygen data available")
                    .padding()
            } else {
                List(fetcher.bloodOxygenRecords.indices, id: \.self) { index in
                    let record = fetcher.bloodOxygenRecords[index]
                    VStack(alignment: .leading, spacing: 5) {
                        Text("Oxygen: \(record["oxygenSaturationPercent"] as? Double ?? 0)%")
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
        .onAppear {
            fetcher.requestAuthorizationAndFetch()
        }
        .navigationTitle("Blood Oxygen")
    }
}
