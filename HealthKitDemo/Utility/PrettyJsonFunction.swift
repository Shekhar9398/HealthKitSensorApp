
import Foundation

func prettyPrintJSON(from dictionary: [String: Any]) {
    let transformed = dictionary.mapValues { value -> Any in
        if let date = value as? Date {
            return ISO8601DateFormatter().string(from: date)
        }
        return value
    }

    do {
        let jsonData = try JSONSerialization.data(withJSONObject: transformed, options: .prettyPrinted)
        if let jsonString = String(data: jsonData, encoding: .utf8) {
            if let vitalName = dictionary["quantityType"] {
                print("--:--\(vitalName)--:--\(jsonString)")
            }
        }
    } catch {
        print("Failed to serialize JSON: \(error)")
    }
}
