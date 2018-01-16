//
//  DefaultsQueue.swift
//  PiwikTracker
//
//  Created by Richard Gravenor on 16/01/2018.
//  Copyright © 2018 PIWIK. All rights reserved.
//

import Foundation

public final class DefaultsQueue: Queue {
    
    private struct Key {
        static let events = "Events"
    }
    
    private let defaults: UserDefaults
    
    public init(withDefaults defaults: UserDefaults = UserDefaults.standard) {
        self.defaults = defaults
    }
    
    public var eventCount: Int {
        return storedEvents.count
    }
    
    private var storedEvents: [Event] {
        get {
            do {
                guard let eventsData = defaults.value(forKey: Key.events) as? Data else { return [] }
                let events: [Event] = try JSONDecoder().decode([Event].self, from: eventsData)
                return events
            } catch {
                PiwikTracker.shared?.logger.error("*** Failed to decode events. Removing all stored events ***")
                removeIncompatibleEvents()
            }
            return []
        }
        
        set {
            do {
                let eventsData = try JSONEncoder().encode(newValue)
                defaults.setValue(eventsData, forKey: Key.events)
            } catch {
                PiwikTracker.shared?.logger.error("*** Failed to encode and store events ***")
            }
        }
    }
    
    public func enqueue(events: [Event], completion: (()->())?) {
        assertMainThread()
        storedEvents.append(contentsOf: events)
        print("Enqueue: stored events: \(storedEvents.count)")
        completion?()
    }
    
    
    public func first(limit: Int, completion: ([Event]) -> ()) {
        assertMainThread()
        let amount = [limit,self.eventCount].min()!
        let dequeuedItems = Array(storedEvents[0..<amount])
        completion(dequeuedItems)
    }
    
    public func remove(events: [Event], completion: () -> ()) {
        assertMainThread()
        storedEvents = storedEvents.filter({ event in !events.contains(where: { eventToRemove in eventToRemove.uuid == event.uuid })})
        print("Removing events: remaining stored events: \(storedEvents.count)")
        completion()
    }
    
    private func removeIncompatibleEvents() {
        defaults.setValue(nil, forKey: Key.events)
    }
}
