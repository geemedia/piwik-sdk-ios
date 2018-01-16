//
//  Event.swift
//  PiwikTracker
//
//  Created by Cornelius Horstmann on 21.12.16.
//  Copyright © 2016 PIWIK. All rights reserved.
//

import Foundation
import CoreGraphics

/// Represents an event of any kind.
///
/// - Note: Should we store the resolution in the Event (cleaner) or add it before transmission (smaller)?
/// - Todo: 
///     - Add Campaign Parameters: _rcn, _rck
///     - Add Action info
///     - Event Tracking info
///     - Add Content Tracking info
///     - Add Ecommerce info
///
/// # Key Mapping:
/// Most properties represent a key defined at: [Tracking HTTP API](https://developer.piwik.org/api-reference/tracking-api). Keys that are not supported for now are:
///
/// - idsite, rec, rand, apiv, res, cookie,
/// - All Plugins: fla, java, dir, qt, realp, pdf, wma, gears, ag
/// - cid: We will use the uid instead of the cid.
public class Event: NSObject, NSCoding {
    let siteId: String
    let uuid: NSUUID
    let visitor: Visitor
    let session: Session
    
    /// The Date and Time the event occurred.
    /// api-key: h, m, s
    let date: Date
    
    /// The full URL for the current action. 
    /// api-key: url
    let url: URL?
    
    /// api-key: action_name
    let actionName: [String]
    
    /// The language of the device.
    /// Should be in the format of the Accept-Language HTTP header field.
    /// api-key: lang
    let language: String
    
    /// Should be set to true for the first event of a session.
    /// api-key: new_visit
    let isNewSession: Bool
    
    /// Currently only used for Campaigns
    /// api-key: urlref
    let referer: URL?
    let screenResolution : CGSize = Device.makeCurrentDevice().screenSize
    /// api-key: _cvar
    //let customVariables: [CustomVariable]
    
    /// Event tracking
    /// https://piwik.org/docs/event-tracking/
    let eventCategory: String?
    let eventAction: String?
    let eventName: String?
    let eventValue: Float?
    
    let dimensions: [CustomDimension]
    
    let customTrackingParameters: [String:String]
    
    init(siteId: String,
         uuid: NSUUID,
         visitor: Visitor,
         session: Session,
         date: Date,
         url: URL,
         actionName: [String],
         language: String,
         isNewSession: Bool,
         referer: URL?,
         eventCategory: String?,
         eventAction: String?,
         eventName: String?,
         eventValue: Float?,
         dimensions: [CustomDimension],
         customTrackingParameters: [String:String]) {
        self.siteId = siteId
        self.uuid = uuid
        self.visitor = visitor
        self.session = session
        self.date = date
        self.url = url
        self.actionName = actionName
        self.language = language
        self.isNewSession = isNewSession
        self.referer = referer
        self.eventCategory = eventCategory
        self.eventAction = eventAction
        self.eventName = eventName
        self.eventValue = eventValue
        self.dimensions = dimensions
        self.customTrackingParameters = customTrackingParameters
    }
    
    public init(tracker: PiwikTracker,
                action: [String],
                url: URL? = nil,
                referer: URL? = nil,
                eventCategory: String? = nil,
                eventAction: String? = nil,
                eventName: String? = nil,
                eventValue: Float? = nil,
                customTrackingParameters: [String:String] = [:],
                dimensions: [CustomDimension] = []) {
        
        self.siteId = tracker.siteId
        self.uuid = NSUUID()
        self.visitor = tracker.visitor
        self.session = tracker.session
        self.date = Date()
        self.url = url ?? tracker.contentBase?.appendingPathComponent(action.joined(separator: "/"))
        self.actionName = action
        self.language = Locale.httpAcceptLanguage
        self.isNewSession = tracker.nextEventStartsANewSession
        self.referer = referer
        self.eventCategory = eventCategory
        self.eventAction = eventAction
        self.eventName = eventName
        self.eventValue = eventValue
        self.dimensions = tracker.dimensions + dimensions
        self.customTrackingParameters = customTrackingParameters
    }
    
    required public init(coder aDecoder: NSCoder) {
        siteId = aDecoder.decodeObject(forKey: "siteId") as? String ?? ""
        uuid = aDecoder.decodeObject(forKey: "uuid") as? NSUUID ?? NSUUID()
        visitor = aDecoder.decodeObject(forKey: "visitor") as? Visitor ?? Visitor(id: "", userId: nil)
        session = aDecoder.decodeObject(forKey: "session") as? Session ?? Session(sessionsCount: 0, lastVisit: Date(), firstVisit: Date())
        date = aDecoder.decodeObject(forKey: "date") as? Date ?? Date()
        url = aDecoder.decodeObject(forKey: "url") as? URL ?? URL(string: "http://www.duff.com")
        actionName = aDecoder.decodeObject(forKey: "actionName") as? [String] ?? []
        language = aDecoder.decodeObject(forKey: "language") as? String ?? ""
        isNewSession = aDecoder.decodeBool(forKey: "isNewSession")
        referer = aDecoder.decodeObject(forKey: "referer") as? URL
        eventCategory = aDecoder.decodeObject(forKey: "eventCategory") as? String
        eventAction = aDecoder.decodeObject(forKey: "eventAction") as? String
        eventName = aDecoder.decodeObject(forKey: "eventName") as? String
        eventValue = aDecoder.decodeObject(forKey: "eventValue") as? Float ?? 0.0
        dimensions = aDecoder.decodeObject(forKey: "dimensions") as? [CustomDimension] ?? []
        customTrackingParameters = aDecoder.decodeObject(forKey: "customTrackingParameters") as? [String:String] ?? [:]
    }
    
    public func encode(with aCoder: NSCoder) {
        aCoder.encode(siteId, forKey: "siteId")
        aCoder.encode(uuid, forKey: "uuid")
        aCoder.encode(visitor, forKey: "visitor")
        aCoder.encode(session, forKey: "session")
        aCoder.encode(date, forKey: "date")
        aCoder.encode(url, forKey: "url")
        aCoder.encode(actionName, forKey: "actionName")
        aCoder.encode(language, forKey: "language")
        aCoder.encode(isNewSession, forKey: "isNewSession")
        aCoder.encode(referer, forKey: "referer")
        aCoder.encode(screenResolution, forKey: "screenResolution")
        aCoder.encode(eventCategory, forKey: "eventCategory")
        aCoder.encode(eventAction, forKey: "eventAction")
        aCoder.encode(eventName, forKey: "eventName")
        aCoder.encode(eventValue, forKey: "eventValue")
        aCoder.encode(dimensions, forKey: "dimensions")
        aCoder.encode(customTrackingParameters, forKey: "customTrackingParameters")
    }
}
