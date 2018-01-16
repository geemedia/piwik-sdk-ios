//
//  Visitor.swift
//  PiwikTracker
//
//  Created by Cornelius Horstmann on 26.02.17.
//  Copyright © 2017 PIWIK. All rights reserved.
//

import Foundation

public class Visitor: NSObject, NSCoding {
    /// Unique ID per visitor (device in this case). Should be
    /// generated upon first start and never changed after.
    /// api-key: _id
    let id: String
    
    /// An optional user identifier such as email or username.
    /// api-key: uid
    let userId: String?
    
    init(id: String, userId: String?) {
        self.id = id
        self.userId = userId
    }
    
    required public init(coder aDecoder: NSCoder) {
        self.id = aDecoder.decodeObject(forKey: "id") as? String ?? ""
        self.userId = aDecoder.decodeObject(forKey: "userId") as? String ?? ""
    }
    
    public func encode(with aCoder: NSCoder) {
        aCoder.encode(id, forKey: "id")
        aCoder.encode(userId, forKey: "userId")
    }
}

extension Visitor {
    static func current() -> Visitor {
        let id: String
        if let existingId = PiwikUserDefaults.standard.clientId {
            id = existingId
        } else {
            let newId = newVisitorID()
            PiwikUserDefaults.standard.clientId = newId
            id = newId
        }
        let userId = PiwikUserDefaults.standard.visitorUserId
        return Visitor(id: id, userId: userId)
    }
    
    static func newVisitorID() -> String {
        let uuid = UUID().uuidString
        let sanitizedUUID = uuid.replacingOccurrences(of: "-", with: "")
        let start = sanitizedUUID.startIndex
        let end = sanitizedUUID.index(start, offsetBy: 16)
        return String(sanitizedUUID[start..<end])
    }
}
