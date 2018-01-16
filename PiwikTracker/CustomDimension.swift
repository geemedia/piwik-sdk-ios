import Foundation

/// For more information on custom dimensions visit https://piwik.org/docs/custom-dimensions/
public class CustomDimension: NSObject, NSCoding {
    /// The index of the dimension. A dimension with this index must be setup in the piwik backend.
    let index: Int
    
    /// The value you want to set for this dimension.
    let value: String
    
    public init(index: Int, value: String) {
      self.index = index
      self.value = value
    }
    
    required public init(coder aDecoder: NSCoder) {
        self.index = aDecoder.decodeInteger(forKey: "index")
        self.value = aDecoder.decodeObject(forKey: "value") as? String ?? ""
    }
    
    public func encode(with aCoder: NSCoder) {
        aCoder.encode(index, forKey: "index")
        aCoder.encode(value, forKey: "value")
    }
}
