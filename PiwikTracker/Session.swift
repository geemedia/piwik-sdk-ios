//
//  Session.swift
//  PiwikTracker
//
//  Created by Cornelius Horstmann on 26.02.17.
//  Copyright © 2017 PIWIK. All rights reserved.
//

import Foundation

struct Session: Codable {
    /// The number of sessions of the current user.
    /// api-key: _idvc
    let sessionsCount: Int
    
    /// The timestamp of the previous visit.
    /// Discussion: Should this be now for the first request?
    /// api-key: _viewts
    let lastVisit: Date
    
    /// The timestamp of the fist visit.
    /// Discussion: Should this be now for the first request?
    /// api-key: _idts
    let firstVisit: Date
    
    init(sessionsCount: Int, lastVisit: Date, firstVisit: Date) {
        self.sessionsCount = sessionsCount
        self.lastVisit = lastVisit
        self.firstVisit = firstVisit
    }
}

extension Session {
    static func current() -> Session {
        let firstVisit: Date
        if let existingFirstVisit = PiwikUserDefaults.standard.firstVisit {
            firstVisit = existingFirstVisit
        } else {
            firstVisit = Date()
            PiwikUserDefaults.standard.firstVisit = firstVisit
        }
        let sessionCount = PiwikUserDefaults.standard.totalNumberOfVisits
        let lastVisit = PiwikUserDefaults.standard.previousVisit ?? Date()
        return Session(sessionsCount: sessionCount, lastVisit: lastVisit, firstVisit: firstVisit)
    }
}
