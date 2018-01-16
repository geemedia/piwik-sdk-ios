//
//  DefaultsQueueSpec.swift
//  PiwikTrackerTests
//
//  Created by Richard Gravenor on 16/01/2018.
//  Copyright © 2018 PIWIK. All rights reserved.
//

import UIKit
import Quick
import Nimble

@testable import PiwikTracker

class DefaultsQueueSpec: QuickSpec {
    override func spec() {
        describe("init") {
            it("should return not null") {
                let queue = DefaultsQueue()
                expect(queue).toNot(beNil())
            }
        }
        describe("eventCount") {
            context("with an empty queue") {
                let queue = DefaultsQueueFixture.empty(withDefaults: UserDefaultsFake())
                it("should return 0") {
                    expect(queue.eventCount) == 0
                }
            }
            context("with a queue with two items") {
                let queue = DefaultsQueueFixture.withTwoItems(withDefaults: UserDefaultsFake())
                it("should return 2") {
                    expect(queue.eventCount) == 2
                }
            }
        }
        describe("enqueue") {
            it("should increase item count") {
                var queue = DefaultsQueueFixture.empty(withDefaults: UserDefaultsFake())
                queue.enqueue(event: EventFixture.event())
                expect(queue.eventCount).toEventually(equal(1))
            }
            it("encode and store the event in an events array in defaults") {
                let defaults = UserDefaultsFake()
                var queue = DefaultsQueueFixture.empty(withDefaults: defaults)
                queue.enqueue(event: EventFixture.event())
                let data = defaults.value(forKey: "Events") as! Data
                let events = try! JSONDecoder().decode([Event].self, from: data)
                expect(events.count).toEventually(equal(1))
            }
            it("should call the completion closure") {
                var queue = DefaultsQueueFixture.empty(withDefaults: UserDefaultsFake())
                var calledClosure = false
                queue.enqueue(event: EventFixture.event(), completion: {
                    calledClosure = true
                })
                expect(calledClosure).toEventually(beTrue())
            }
            it("should enqueue the object") {
                var queue = DefaultsQueueFixture.empty(withDefaults: UserDefaultsFake())
                let event = EventFixture.event()
                var dequeued: Event? = nil
                queue.enqueue(event: event)
                queue.first(limit: 1) { event in
                    dequeued = event.first
                }
                expect(dequeued).toEventuallyNot(beNil())
                expect(dequeued?.uuid).toEventually(equal(event.uuid))
            }
        }
        describe("first") {
            context("with an empty queue") {
                let queue = DefaultsQueueFixture.empty(withDefaults: UserDefaultsFake())
                it("should call the completionblock without items") {
                    var dequeuedItems: [Any]? = nil
                    queue.first(limit: 10) { events in
                        dequeuedItems = events
                    }
                    expect(dequeuedItems).toEventuallyNot(beNil())
                    expect(dequeuedItems?.count).toEventually(equal(0))
                }
            }
            context("with a queue with two items") {
                it("should fetch and decode the event from defaults") {
                    let defaults = UserDefaultsFake()
                    let eventsData = try! JSONEncoder().encode([EventFixture.event()])
                    defaults.setValue(eventsData, forKey: "Events")
                    let queue = DefaultsQueueFixture.empty(withDefaults: defaults)
                    
                    var dequeuedItems: [Any]? = nil
                    queue.first(limit: 1) { events in
                        dequeuedItems = events
                    }
                    let dequeuedEvent = dequeuedItems!.first! as! Event
                    expect(dequeuedEvent.siteId).to(equal("spec_1"))
                }
                it("should return one item if just asked for one") {
                    let queue = DefaultsQueueFixture.withTwoItems(withDefaults: UserDefaultsFake())
                    var dequeuedItems: [Any]? = nil
                    queue.first(limit: 1) { events in
                        dequeuedItems = events
                    }
                    expect(dequeuedItems?.count).toEventually(equal(1))
                }
                it("should return two items if asked for two or more") {
                    let queue = DefaultsQueueFixture.withTwoItems(withDefaults: UserDefaultsFake())
                    var dequeuedItems: [Any]? = nil
                    queue.first(limit: 10) { events in
                        dequeuedItems = events
                    }
                    expect(dequeuedItems?.count).toEventually(equal(2))
                }
                it("should not remove objects from the queue") {
                    let queue = DefaultsQueueFixture.withTwoItems(withDefaults: UserDefaultsFake())
                    queue.first(limit: 1, completion: { items in })
                    expect(queue.eventCount) == 2
                }
            }
        }
        describe("remove") {
            it("should remove events that are enqueued") {
                let queue = DefaultsQueueFixture.withTwoItems(withDefaults: UserDefaultsFake())
                var dequeuedItem: Event? = nil
                queue.first(limit: 1) { events in
                    dequeuedItem = events.first
                }
                queue.remove(events: [dequeuedItem!], completion: {})
                expect(queue.eventCount) == 1
            }
            it("should remove events from defaults that are enqueued") {
                let defaults = UserDefaultsFake()
                let eventsData = try! JSONEncoder().encode([EventFixture.event()])
                defaults.setValue(eventsData, forKey: "Events")
                
                let queue = DefaultsQueueFixture.empty(withDefaults: defaults)
                var dequeuedItem: Event? = nil
                queue.first(limit: 1) { events in
                    dequeuedItem = events.first
                }
                queue.remove(events: [dequeuedItem!], completion: {})
                
                let decodedEventsData = defaults.value(forKey: "Events") as! Data
                let decodedEvents = try! JSONDecoder().decode([Event].self, from: decodedEventsData)
                
                expect(decodedEvents.count) == 0
            }
            it("should ignore if one event is tried to remove twice") {
                let queue = DefaultsQueueFixture.withTwoItems(withDefaults: UserDefaultsFake())
                var dequeuedItem: Event? = nil
                queue.first(limit: 1) { events in
                    dequeuedItem = events.first
                }
                queue.remove(events: [dequeuedItem!], completion: {})
                queue.remove(events: [dequeuedItem!], completion: {})
                expect(queue.eventCount) == 1
            }
            it("should skip not queued events") {
                let queue = DefaultsQueueFixture.withTwoItems(withDefaults: UserDefaultsFake())
                var dequeuedItem: Event? = nil
                queue.first(limit: 1) { events in
                    dequeuedItem = events.first
                }
                queue.remove(events: [dequeuedItem!, EventFixture.event()], completion: {})
                expect(queue.eventCount) == 1
            }
        }
    }

}


