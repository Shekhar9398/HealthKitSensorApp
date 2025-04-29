import SwiftUI

struct FlightsClimbedView: View {
    @StateObject private var fetcher = FlightsClimbedDataFetcher.shared

    var body: some View {
        VStack {
            Button("Fetch Flights Climbed Data") {
                fetcher.requestAuthorizationAndFetch()
            }
            .padding()

            if let records = fetcher.flightsClimbedData["records"] as? [[String: Any]], !records.isEmpty {
                List {
                    ForEach(records.indices, id: \.self) { index in
                        let record = records[index]
                        VStack(alignment: .leading, spacing: 5) {
                            Text("Flights Climbed: \(record["flightsClimbed"] as? Int ?? 0)")
                            if let startDate = record["startDate"] as? Date {
                                Text("Start: \(startDate.formatted(date: .abbreviated, time: .shortened))")
                            }
                            if let endDate = record["endDate"] as? Date {
                                Text("End: \(endDate.formatted(date: .abbreviated, time: .shortened))")
                            }
                            if let uuid = record["UUID"] as? String {
                                Text("UUID: \(uuid)")
                                    .font(.caption)
                                    .foregroundColor(.gray)
                            }
                        }
                        .padding(.vertical, 5)
                    }
                }
            } else {
                Spacer()
                Text("No Flights Climbed Data available.")
                    .foregroundColor(.secondary)
                    .padding()
            }
        }
        .navigationTitle("Flights Climbed")
        .onAppear {
            fetcher.requestAuthorizationAndFetch()
        }
    }
}

struct FlightsClimbedView_Previews: PreviewProvider {
    static var previews: some View {
        FlightsClimbedView()
    }
}
