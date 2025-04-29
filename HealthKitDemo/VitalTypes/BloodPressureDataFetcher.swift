import HealthKit
import Combine

class BloodPressureDataFetcher: ObservableObject {
    static let shared = BloodPressureDataFetcher()
    
    private let healthStore = HKHealthStore()
    @Published var bloodPressureData: [String: Any] = [:]
    
    private init() {}

    // MARK: - Authorization Entry Point
    func requestAuthorizationAndFetch() {
        guard let systolicType = HKQuantityType.quantityType(forIdentifier: .bloodPressureSystolic),
              let diastolicType = HKQuantityType.quantityType(forIdentifier: .bloodPressureDiastolic) else {
            print("Blood pressure types are unavailable.")
            return
        }
        
        let readTypes: Set<HKObjectType> = [systolicType, diastolicType]
        
        healthStore.requestAuthorization(toShare: nil, read: readTypes) { success, error in
            if success {
                self.fetchAllBloodPressureRecords { result in
                    if let result = result {
                        DispatchQueue.main.async {
                            self.bloodPressureData = result
                            print("All Blood Pressure Records in 24 Hours:")
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
    func fetchAllBloodPressureRecords(completion: @escaping ([String: Any]?) -> Void) {
        guard let systolicType = HKQuantityType.quantityType(forIdentifier: .bloodPressureSystolic),
              let diastolicType = HKQuantityType.quantityType(forIdentifier: .bloodPressureDiastolic) else {
            completion(nil)
            return
        }

        let now = Date()
        let start = Calendar.current.date(byAdding: .hour, value: -24, to: now)!
        let predicate = HKQuery.predicateForSamples(withStart: start, end: now, options: .strictStartDate)

        let systolicQuery = HKSampleQuery(sampleType: systolicType, predicate: predicate, limit: HKObjectQueryNoLimit, sortDescriptors: nil) { _, systolicSamples, _ in
            guard let systolicSamples = systolicSamples as? [HKQuantitySample] else {
                completion(nil)
                return
            }

            let diastolicQuery = HKSampleQuery(sampleType: diastolicType, predicate: predicate, limit: HKObjectQueryNoLimit, sortDescriptors: nil) { _, diastolicSamples, _ in
                guard let diastolicSamples = diastolicSamples as? [HKQuantitySample] else {
                    completion(nil)
                    return
                }

                var combinedResults: [[String: Any]] = []

                for systolic in systolicSamples {
                    if let diastolic = diastolicSamples.first(where: { $0.startDate == systolic.startDate }) {
                        let record: [String: Any] = [
                            "quantityType": "bloodPressure",
                            "UUID": systolic.uuid.uuidString,
                            "startDate": systolic.startDate,
                            "endDate": systolic.endDate,
                            "systolic": systolic.quantity.doubleValue(for: HKUnit.millimeterOfMercury()),
                            "diastolic": diastolic.quantity.doubleValue(for: HKUnit.millimeterOfMercury())
                        ]
                        combinedResults.append(record)
                    }
                }

                completion(["records": combinedResults])
            }
            self.healthStore.execute(diastolicQuery)
        }
        healthStore.execute(systolicQuery)
    }
}

