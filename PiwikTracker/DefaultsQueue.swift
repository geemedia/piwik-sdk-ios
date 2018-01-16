//
//  DefaultsQueue.swift
//  PiwikTracker
//
//  Created by Richard Gravenor on 16/01/2018.
//  Copyright © 2018 PIWIK. All rights reserved.
//

import Foundation

class CustomDefaults: UserDefaults {
    override func synchronize() -> Bool {
        print("Syncronised")
        return super.synchronize()
    }
}

public final class DefaultsQueue: Queue {
    
    private struct Key {
        static let events = "Events"
    }
    
    public init() {}
    
    public var eventCount: Int {
        return storedEvents.count
    }
    
    // TODO: RG - Will require optimisation or replacement with CD:
    private var storedEvents: [Event] {
        get {
            do {
                guard
                    let eventsData = CustomDefaults.standard.value(forKey: Key.events) as? Data,
                    let events = try NSKeyedUnarchiver.unarchiveTopLevelObjectWithData(eventsData) as? [Event] else { return [] }
                return events
            } catch {
                CustomDefaults.standard.setValue(nil, forKey: Key.events)
            }
            
            return []
        }
        
        set {
            let eventsData = NSKeyedArchiver.archivedData(withRootObject: newValue)
            CustomDefaults.standard.setValue(eventsData, forKey: Key.events)
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
}
