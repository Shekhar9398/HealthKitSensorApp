import SwiftUI

enum HealthViewType: String, CaseIterable {
    case bloodOxygen = "Blood Oxygen"
    case bloodPressure = "Blood Pressure"
    case flightsClimbed = "Flights Climbed"
    case heartRate = "Heart Rate"
    case respirationRate = "Respiration Rate"
    case sleep = "Sleep"
    case step = "Step"
    case weight = "weight"
    case elevation = "elevation"
}

struct ContentView: View {
    @State private var selectedView: HealthViewType? = nil

    var body: some View {
        NavigationStack {
            VStack {
                // Buttons to select view
                ForEach(HealthViewType.allCases, id: \.self) { type in
                    Button(action: {
                        selectedView = type
                    }) {
                        Text(type.rawValue)
                            .font(.headline)
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(Color.blue.opacity(0.1))
                            .cornerRadius(8)
                    }
                    .padding(.horizontal)
                }

                Divider().padding()

                // Show selected view
                if let type = selectedView {
                    switch type {
                    case .bloodOxygen:
                        BloodOxygenView()
                    case .bloodPressure:
                        BloodPressureView()
                    case .flightsClimbed:
                        FlightsClimbedView()
                    case .heartRate:
                        HeartRateView()
                    case .respirationRate:
                        RespirationRateView()
                    case .sleep:
                        SleepDataView()
                    case .step:
                        StepView()
                    case .elevation:
                        ElevationView()
                    case .weight:
                        WeightDataView()
                    }
                } else {
                    Text("Select a health data type above")
                        .foregroundColor(.gray)
                        .padding()
                }
            }
            .navigationTitle("Health Dashboard")
        }
    }
}

#Preview {
    ContentView()
}
