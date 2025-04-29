import HealthKit
import Combine

class BloodOxygenDataFetcher: ObservableObject {
    static let shared = BloodOxygenDataFetcher()

    private let healthStore = HKHealthStore()
    @Published var bloodOxygenRecords: [[String: Any]] = []

    private init() {}

    func requestAuthorizationAndFetch() {
        guard let oxygenSaturationType = HKQuantityType.quantityType(forIdentifier: .oxygenSaturation) else {
            print("Oxygen saturation type is unavailable.")
            return
        }

        let readTypes: Set<HKObjectType> = [oxygenSaturationType]

        healthStore.requestAuthorization(toShare: nil, read: readTypes) { success, error in
            if success {
                self.fetchData()
            } else {
                print("Authorization failed: \(error?.localizedDescription ?? "Unknown error")")
            }
        }
    }

    private func fetchData() {
        guard let quantityType = HKQuantityType.quantityType(forIdentifier: .oxygenSaturation) else {
            print("Failed to get quantity type for oxygen saturation")
            return
        }

        let now = Date()
        let start = Calendar.current.date(byAdding: .hour, value: -24, to: now)!
        let predicate = HKQuery.predicateForSamples(withStart: start, end: now, options: .strictStartDate)

        let query = HKSampleQuery(sampleType: quantityType, predicate: predicate, limit: HKObjectQueryNoLimit, sortDescriptors: nil) { _, samples, _ in
            guard let samples = samples as? [HKQuantitySample], !samples.isEmpty else {
                print("No oxygen data available")
                return
            }

            var records: [[String: Any]] = []

            for sample in samples {
                let record: [String: Any] = [
                    "quantityType": "oxygenSaturation",
                    "UUID": sample.uuid.uuidString,
                    "startDate": sample.startDate,
                    "endDate": sample.endDate,
                    "oxygenSaturationPercent": sample.quantity.doubleValue(for: HKUnit.percent())
                ]
                records.append(record)
            }

            DispatchQueue.main.async {
                self.bloodOxygenRecords = records
                print("All Blood Oxygen Records in 24 Hours:")
                for record in records {
                    prettyPrintJSON(from: record)
                }
            }
        }

        healthStore.execute(query)
    }
}
