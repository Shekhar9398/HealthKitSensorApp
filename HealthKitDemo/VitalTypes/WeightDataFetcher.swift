import HealthKit
import Combine

class WeightDataFetcher: ObservableObject {
    private let healthStore = HKHealthStore()
    @Published var weightData: [String: Any] = [:]

    // Entry point for requesting authorization and fetching weight
    func requestAuthorizationAndFetch(completion: @escaping (Bool) -> Void) {
        guard let quantityType = HKQuantityType.quantityType(forIdentifier: .bodyMass) else {
            print("Body mass type is unavailable.")
            completion(false)
            return
        }

        let readTypes: Set<HKObjectType> = [quantityType]

        healthStore.requestAuthorization(toShare: nil, read: readTypes) { success, error in
            if success {
                self.fetchWeight { result in
                    if let result = result {
                        DispatchQueue.main.async {
                            self.weightData = result
                            print("Latest Weight Record:")
                            if let record = result["weightData"] as? [String: Any] {
                                prettyPrintJSON(from: record)
                            }
                        }
                    }
                    completion(success)
                }
            } else {
                print("Authorization failed: \(error?.localizedDescription ?? "Unknown error")")
                completion(false)
            }
        }
    }

    // Internal method to fetch latest weight data
    private func fetchWeight(completion: @escaping ([String: Any]?) -> Void) {
        guard let quantityType = HKQuantityType.quantityType(forIdentifier: .bodyMass) else {
            completion(nil)
            return
        }

        let now = Date()
        let start = Calendar.current.date(byAdding: .hour, value: -1, to: now)!
        let predicate = HKQuery.predicateForSamples(withStart: start, end: now, options: .strictStartDate)

        let query = HKSampleQuery(sampleType: quantityType, predicate: predicate, limit: 1, sortDescriptors: nil) { _, samples, _ in
            guard let sample = samples?.first as? HKQuantitySample else {
                completion(nil)
                return
            }

            let data: [String: Any] = [
                "quantity": sample.quantity.doubleValue(for: HKUnit.pound()),
                "quantityType": "bodyMass",
                "UUID": sample.uuid.uuidString,
                "startDate": ISO8601DateFormatter().string(from: sample.startDate),
                "endDate": ISO8601DateFormatter().string(from: sample.endDate),
                "weightPounds": sample.quantity.doubleValue(for: HKUnit.pound())
            ]
            completion(["weightData": data])
        }

        healthStore.execute(query)
    }
}
