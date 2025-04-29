import SwiftUI

struct WeightDataView: View {
    @StateObject private var weightDataFetcher = WeightDataFetcher()
    @State private var isFetching = false
    
    var body: some View {
        VStack {
            if isFetching {
                ProgressView("Fetching Data...")
                    .progressViewStyle(CircularProgressViewStyle())
                    .padding()
            } else {
                if let weight = weightDataFetcher.weightData["weightData"] as? [String: Any],
                   let weightPounds = weight["weightPounds"] as? Double {
                    Text("Latest Weight:")
                        .font(.headline)
                        .padding(.top)
                    
                    Text(String(format: "%.2f lbs", weightPounds))
                        .font(.title)
                        .padding()
                    
                    Text("Start Date: \(weight["startDate"] as? String ?? "N/A")")
                    Text("End Date: \(weight["endDate"] as? String ?? "N/A")")
                } else {
                    Text("No weight data available")
                        .foregroundColor(.red)
                }
                
                Button(action: fetchWeightData) {
                    Text("Fetch Latest Weight")
                        .fontWeight(.bold)
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(8)
                }
                .padding()
            }
        }
        .onAppear {
            fetchWeightData()
        }
    }
    
    private func fetchWeightData() {
        isFetching = true
        weightDataFetcher.requestAuthorizationAndFetch { success in
            isFetching = false
            if !success {
                print("Failed to fetch weight data")
            }
        }
    }
}

struct WeightDataView_Previews: PreviewProvider {
    static var previews: some View {
        WeightDataView()
    }
}
