import HealthKit
import Combine

class FlightsClimbedDataFetcher: ObservableObject {
    static let shared = FlightsClimbedDataFetcher()

    private let healthStore = HKHealthStore()
    @Published var flightsClimbedData: [String: Any] = [:]

    private init() {}

    // MARK: - Authorization Entry Point
    func requestAuthorizationAndFetch() {
        guard let flightsClimbedType = HKQuantityType.quantityType(forIdentifier: .flightsClimbed) else {
            print("Flights climbed type is unavailable.")
            return
        }

        let readTypes: Set<HKObjectType> = [flightsClimbedType]

        healthStore.requestAuthorization(toShare: nil, read: readTypes) { success, error in
            if success {
                self.fetchFlightsClimbedData { result in
                    if let result = result {
                        DispatchQueue.main.async {
                            self.flightsClimbedData = result
                            print("All Flights Climbed Records in 24 Hours:")
                            if let records = result["records"] as? [[String: Any]] {
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
        }
    }

    // MARK: - Public Fetch Method
    func fetchFlightsClimbedData(completion: @escaping ([String: Any]?) -> Void) {
        guard let flightsClimbedType = HKQuantityType.quantityType(forIdentifier: .flightsClimbed) else {
            completion(nil)
            return
        }

        let now = Date()
        let start = Calendar.current.date(byAdding: .hour, value: -24, to: now)!
        let predicate = HKQuery.predicateForSamples(withStart: start, end: now, options: .strictStartDate)

        let query = HKSampleQuery(sampleType: flightsClimbedType, predicate: predicate, limit: HKObjectQueryNoLimit, sortDescriptors: nil) { _, samples, _ in
            guard let samples = samples as? [HKQuantitySample] else {
                completion(nil)
                return
            }

            var combinedResults: [[String: Any]] = []

            for sample in samples {
                let record: [String: Any] = [
                    "quantityType": "flightsClimbed",
                    "UUID": sample.uuid.uuidString,
                    "startDate": sample.startDate,
                    "endDate": sample.endDate,
                    "flightsClimbed": Int(sample.quantity.doubleValue(for: HKUnit.count()))
                ]
                combinedResults.append(record)
            }

            completion(["records": combinedResults])
        }

        healthStore.execute(query)
    }
}
