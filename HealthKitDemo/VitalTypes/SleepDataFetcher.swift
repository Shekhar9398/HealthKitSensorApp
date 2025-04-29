import HealthKit
import Combine

class SleepDataFetcher: ObservableObject {
    private let healthStore = HKHealthStore()
    @Published var sleepData: [String: Any] = [:]
    
    // MARK: - Authorization Entry Point
    func requestAuthorizationAndFetch(completion: @escaping (Bool) -> Void) {
        guard let sleepType = HKCategoryType.categoryType(forIdentifier: .sleepAnalysis) else {
            print("Sleep analysis type is unavailable.")
            completion(false)
            return
        }

        let readTypes: Set<HKObjectType> = [sleepType]
        
        healthStore.requestAuthorization(toShare: nil, read: readTypes) { success, error in
            if success {
                self.fetchSleepData { result in
                    if let result = result {
                        DispatchQueue.main.async {
                            self.sleepData = result
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
    func fetchSleepData(completion: @escaping ([String: Any]?) -> Void) {
        guard let sleepType = HKCategoryType.categoryType(forIdentifier: .sleepAnalysis) else {
            completion(nil)
            return
        }

        let now = Date()
        let start = Calendar.current.date(byAdding: .hour, value: -24, to: now)!
        let predicate = HKQuery.predicateForSamples(withStart: start, end: now, options: .strictStartDate)

        let query = HKSampleQuery(sampleType: sleepType, predicate: predicate, limit: HKObjectQueryNoLimit, sortDescriptors: nil) { _, samples, _ in
            guard let samples = samples as? [HKCategorySample], !samples.isEmpty else {
                completion(nil)
                return
            }

            var resultData: [[String: Any]] = []
            
            for sample in samples {
                let startDateString = self.formatDate(sample.startDate)
                let endDateString = self.formatDate(sample.endDate)

                // Determine sleep category
                let sleepCategory: String
                switch sample.value {
                case HKCategoryValueSleepAnalysis.asleep.rawValue:
                    sleepCategory = "Asleep"
                case HKCategoryValueSleepAnalysis.awake.rawValue:
                    sleepCategory = "Awake"
                case HKCategoryValueSleepAnalysis.inBed.rawValue:
                    sleepCategory = "In Bed"
                default:
                    sleepCategory = "Unknown"
                }

                let data: [String: Any] = [
                    "UUID": sample.uuid.uuidString,
                    "startDate": startDateString,
                    "endDate": endDateString,
                    "category": sleepCategory,
                    "durationMinutes": sample.endDate.timeIntervalSince(sample.startDate) / 60
                ]
                resultData.append(data)
            }

            // Pretty print the sleep data
            if let jsonData = try? JSONSerialization.data(withJSONObject: ["sleepData": resultData], options: .prettyPrinted) {
                if let jsonString = String(data: jsonData, encoding: .utf8) {
                    print("All Sleep Records in 24 Hours:")
                    print("--:--sleepData--:-- \(jsonString)")
                }
            }

            completion(["sleepData": resultData])
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
