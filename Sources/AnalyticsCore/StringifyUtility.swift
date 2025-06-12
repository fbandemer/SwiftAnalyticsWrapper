import Foundation

public struct StringifyUtility {
    public static func stringifyParams(params: [String: Any]) -> [String: String] {
        var stringifiedParams: [String: String] = [:]
        for param in params {
            stringifiedParams[param.key] = String(describing: param.value)
        }
        return stringifiedParams
    }
    
    public static func enrichParams(baseAttributes: [String: Any], additionalParams: [String: Any]) -> [String: Any] {
        return baseAttributes.merging(additionalParams) { _, new in new }
    }
}