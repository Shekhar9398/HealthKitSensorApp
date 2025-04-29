import HealthKit
import Combine

class HeartRateDataFetcher: ObservableObject {
    private let healthStore = HKHealthStore()
    @Published var heartRateData: [String: Any] = [:]
    
    // MARK: - Authorization Entry Point
    func requestAuthorizationAndFetch(completion: @escaping (Bool) -> Void) {
        guard let heartRateType = HKQuantityType.quantityType(forIdentifier: .heartRate) else {
            print("Heart rate type is unavailable.")
            completion(false)
            return
        }

        let readTypes: Set<HKObjectType> = [heartRateType]
        
        healthStore.requestAuthorization(toShare: nil, read: readTypes) { success, error in
            if success {
                self.fetchHeartRateRecords { result in
                    if let result = result {
                        DispatchQueue.main.async {
                            self.heartRateData = result
                            print("All Heart Rate Records in 24 Hours:")
                            if let records = result["heartRateData"] as? [[String: Any]] {
                                for record in records {
                                    prettyPrintJSON(from: record)
                                }
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
    
    // MARK: - Public Fetch Method
    func fetchHeartRateRecords(completion: @escaping ([String: Any]?) -> Void) {
        guard let heartRateType = HKQuantityType.quantityType(forIdentifier: .heartRate) else {
            completion(nil)
            return
        }

        let now = Date()
        let start = Calendar.current.date(byAdding: .hour, value: -24, to: now)!
        let predicate = HKQuery.predicateForSamples(withStart: start, end: now, options: .strictStartDate)

        let query = HKSampleQuery(sampleType: heartRateType, predicate: predicate, limit: HKObjectQueryNoLimit, sortDescriptors: nil) { _, samples, _ in
            guard let samples = samples as? [HKQuantitySample], !samples.isEmpty else {
                completion(nil)
                return
            }

            var resultData: [[String: Any]] = []
            
            for sample in samples {
                let startDateString = self.formatDate(sample.startDate)
                let endDateString = self.formatDate(sample.endDate)

                let data: [String: Any] = [
                    "quantity": sample.quantity.doubleValue(for: HKUnit(from: "count/min")),
                    "quantityType": "heartRate",
                    "UUID": sample.uuid.uuidString,
                    "startDate": startDateString,
                    "endDate": endDateString,
                    "bpm": sample.quantity.doubleValue(for: HKUnit(from: "count/min"))
                ]
                resultData.append(data)
            }

            completion(["heartRateData": resultData])
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
