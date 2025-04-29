import HealthKit
import Combine

class ElevationDataFetcher: ObservableObject {
    let healthStore = HKHealthStore()
    @Published var elevationData: [String: Any] = [:]

    /// Request permission and then fetch the single most-recent workout’s elevation data.
    func requestAuthorizationAndFetch(completion: @escaping (Bool) -> Void) {
        let workoutType = HKObjectType.workoutType()
        let readTypes: Set<HKObjectType> = [workoutType]

        healthStore.requestAuthorization(toShare: nil, read: readTypes) { success, error in
            if success {
                self.fetchElevationData { result in
                    DispatchQueue.main.async {
                        self.elevationData = result ?? [:]
                        print("elevationData:", self.elevationData)
                    }
                    completion(true)
                }
            } else {
                print("Authorization failed:", error?.localizedDescription ?? "")
                completion(false)
            }
        }
    }

    /// Fetches the one most-recent workout, across all time.
    private func fetchElevationData(completion: @escaping ([String: Any]?) -> Void) {
        let workoutType = HKObjectType.workoutType()
        // No startDate -> search everything. Sort by endDate descending.
        let predicate = HKQuery.predicateForSamples(withStart: nil, end: Date(), options: .strictEndDate)
        let sortDesc = NSSortDescriptor(key: HKSampleSortIdentifierEndDate, ascending: false)

        let query = HKSampleQuery(
            sampleType: workoutType,
            predicate: predicate,
            limit: 1,
            sortDescriptors: [sortDesc]
        ) { _, samples, error in
            if let error = error {
                print("SampleQuery error:", error.localizedDescription)
                completion(nil)
                return
            }

            guard let workout = samples?.first as? HKWorkout else {
                print("No workouts ever recorded.")
                completion(nil)
                return
            }

            var dataEntry: [String: Any] = [
                "UUID": workout.uuid.uuidString,
                "startDate": ISO8601DateFormatter().string(from: workout.startDate),
                "endDate":   ISO8601DateFormatter().string(from: workout.endDate)
            ]

            if let asc = workout.metadata?[HKMetadataKeyElevationAscended] as? Double {
                dataEntry["elevationAscended"] = asc
            } else {
                dataEntry["elevationAscended"] = 0.0
            }

            if let desc = workout.metadata?[HKMetadataKeyElevationDescended] as? Double {
                dataEntry["elevationDescended"] = desc
            } else {
                dataEntry["elevationDescended"] = 0.0
            }

            completion(dataEntry)
        }

        healthStore.execute(query)
    }
}
