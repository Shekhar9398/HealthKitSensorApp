import SwiftUI
import HealthKit

struct ElevationView: View {
    @StateObject private var elevationDataFetcher = ElevationDataFetcher()

    @State private var isAuthorized = false
    @State private var errorMessage: String?

    var body: some View {
        VStack {
            if let elevationAscended = elevationDataFetcher.elevationData["elevationAscended"] as? Double {
                Text("Elevation Ascended: \(elevationAscended) meters")
                    .font(.title2)
                    .padding()
            } else {
                Text("No Elevation Data Available")
                    .font(.title2)
                    .padding()
            }
            
            if let elevationDescended = elevationDataFetcher.elevationData["elevationDescended"] as? Double {
                Text("Elevation Descended: \(elevationDescended) meters")
                    .font(.title2)
                    .padding()
            }
            
            if !isAuthorized {
                Button("Request Authorization and Fetch Data") {
                    elevationDataFetcher.requestAuthorizationAndFetch { success in
                        if success {
                            isAuthorized = true
                        } else {
                            errorMessage = "Authorization failed. Please check your permissions."
                        }
                    }
                }
                .padding()
                .background(Color.blue)
                .foregroundColor(.white)
                .cornerRadius(10)
            }
            
            if let errorMessage = errorMessage {
                Text(errorMessage)
                    .foregroundColor(.red)
                    .padding()
            }
            
            
        }
        .onAppear {
            if HKHealthStore.isHealthDataAvailable() {
                elevationDataFetcher.requestAuthorizationAndFetch { success in
                    isAuthorized = success
                }
            } else {
                errorMessage = "HealthKit is not available on this device."
            }
        }
        .padding()
    }
}

struct ElevationView_Previews: PreviewProvider {
    static var previews: some View {
        ElevationView()
    }
}
