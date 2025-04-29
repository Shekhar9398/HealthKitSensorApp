import HealthKit
import Combine

class StepDataFetcher: ObservableObject {
    private let healthStore = HKHealthStore()
    @Published var stepData: [String: Any] = [:]

    // MARK: - Public Entry Point
    func requestAuthorizationAndFetch(completion: @escaping (Bool) -> Void) {
        guard let quantityType = HKQuantityType.quantityType(forIdentifier: .stepCount) else {
            completion(false)
            return
        }

        let readTypes: Set<HKObjectType> = [quantityType]
        healthStore.requestAuthorization(toShare: nil, read: readTypes) { success, error in
            if success {
                self.fetchStepData { result in
                    if let result = result {
                        DispatchQueue.main.async {
                            self.stepData = result
                            print("Step Data:")
                            if let record = result["stepData"] as? [String: Any] {
                                prettyPrintJSON(from: record)
                            }
                        }
                    }
                }
            } else {
                print("Authorization failed: \(error?.localizedDescription ?? "Unknown error")")
            }
            completion(success)
        }
    }

    // MARK: - Private Fetch Logic
    private func fetchStepData(completion: @escaping ([String: Any]?) -> Void) {
        guard let quantityType = HKQuantityType.quantityType(forIdentifier: .stepCount) else {
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
                "quantity": Int(sample.quantity.doubleValue(for: HKUnit.count())),
                "quantityType": "stepCount",
                "UUID": sample.uuid.uuidString,
                "startDate": self.formatDate(sample.startDate),
                "endDate": self.formatDate(sample.endDate),
                "count": Int(sample.quantity.doubleValue(for: HKUnit.count()))
            ]
            completion(["stepData": data])
        }
        healthStore.execute(query)
    }

    private func formatDate(_ date: Date) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .short
        dateFormatter.timeStyle = .long
        dateFormatter.timeZone = TimeZone.current
        return dateFormatter.string(from: date)
    }
}
