@testable import PiwikTracker

struct EventFixture {
    static func event() -> Event {
        let visitor = Visitor(id: "spec_visitor_id", userId: "spec_user_id")
        let session = Session(sessionsCount: 0, lastVisit: Date(), firstVisit: Date())
        
        return Event(siteId: "spec_1", uuid: UUID.init(), visitor: visitor, session: session, date: Date(), url: URL(string: "http://spec_url")!, actionName: ["spec_action"], language: "spec_language", isNewSession: true, referer: nil,
                     eventCategory: nil,
                     eventAction: nil,
                     eventName: nil,
                     eventValue: nil,
                     dimensions: [],
                     customTrackingParameters: [:])
    }
}

struct MemoryQueueFixture {
    static func empty() -> MemoryQueue {
        return MemoryQueue()
    }
    static func withTwoItems() -> MemoryQueue {
        var queue = MemoryQueue()
        queue.enqueue(event: EventFixture.event())
        queue.enqueue(event: EventFixture.event())
        return queue
    }
}

struct DefaultsQueueFixture {
    static func empty(withDefaults defaults: UserDefaultsFake) -> DefaultsQueue {
        return DefaultsQueue(withDefaults: defaults)
    }
    static func withTwoItems(withDefaults defaults: UserDefaultsFake) -> DefaultsQueue {
        var queue = DefaultsQueue(withDefaults: defaults)
        queue.enqueue(event: EventFixture.event())
        queue.enqueue(event: EventFixture.event())
        return queue
    }
}

class UserDefaultsFake: UserDefaults {
    var storedData = [String: Any?]()
    
    override func setValue(_ value: Any?, forKey key: String) {
        storedData[key] = value
    }
    
    override func value(forKey key: String) -> Any? {
        if let value = storedData[key] {
            return value
        }
        return nil
    }
}
