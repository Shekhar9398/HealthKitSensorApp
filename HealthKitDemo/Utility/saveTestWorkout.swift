import SwiftUI
import HealthKit

extension ElevationDataFetcher {
  /// Creates and saves a fake workout with non-zero elevation metadata.
  func saveTestWorkout(completion: ((Bool) -> Void)? = nil) {
    let endDate = Date()
    let startDate = Calendar.current.date(byAdding: .minute, value: -15, to: endDate)!
    
    // Choose some non-zero test values:
    let metadata: [String: Any] = [
      HKMetadataKeyElevationAscended: 123.45,
      HKMetadataKeyElevationDescended: 67.89
    ]
    
    let workout = HKWorkout(
      activityType: .walking,
      start: startDate,
      end: endDate,
      workoutEvents: nil,
      totalEnergyBurned: nil,
      totalDistance: nil,
      metadata: metadata
    )
    
    healthStore.save(workout) { success, error in
      DispatchQueue.main.async {
        if success {
          print("✅ Test workout saved with elevation metadata")
        } else {
          print("❌ Failed to save workout:", error?.localizedDescription ?? "")
        }
        completion?(success)
      }
    }
  }
}
