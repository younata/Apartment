import Quick
import Nimble
import UIKit
import Ra
import Apartment
import ApartKit

class HomeViewControllerSpec: QuickSpec {
    override func spec() {
        var subject: HomeViewController! = nil
        var injector: Ra.Injector! = nil
        var lightsService: FakeLightsService! = nil
        var lockService: FakeLockService! = nil
        var navigationController: UINavigationController! = nil
        var appModule: SpecApplicationModule! = nil

        beforeEach {
            injector = Ra.Injector()

            appModule = SpecApplicationModule()
            appModule.configureInjector(injector)

            lightsService = FakeLightsService(backendURL: "", urlSession: NSURLSession.sharedSession(), authenticationToken: "")
            injector.bind(kLightsService, to: lightsService)

            lockService = FakeLockService(backendURL: "", urlSession: NSURLSession.sharedSession(), authenticationToken: "")
            injector.bind(kLockService, to: lockService)

            subject = injector.create(HomeViewController.self) as! HomeViewController
            navigationController = UINavigationController(rootViewController: subject)
        }

        describe("on view load") {
            beforeEach {
                expect(subject.view).toNot(beNil())
            }

            describe("Getting all bulbs") {
                it("should ask for all bulbs") {
                    expect(lightsService.didReceiveAllBulbs).to(beTruthy())
                }

                describe("on all bulbs return") {
                    let bulbs : [Bulb] = [Bulb(id: 3, name: "Hue Lamp 2", on: false, brightness: 194, hue: 15051,
                        saturation: 137, colorTemperature: 359, transitionTime: 10, colorMode: .colorTemperature,
                        effect: .none, reachable: true, alert: "none")]
                    beforeEach {
                        lightsService.allBulbsHandler(bulbs, nil)
                    }

                    it("should set the bulbs value") {
                        expect(subject.bulbs).to(equal(bulbs))
                    }
                }
            }

            describe("Getting all the locks") {
                it("should ask for all locks") {
                    expect(lockService.didReceiveAllLocks).to(beTruthy())
                }

                describe("on all locks return") {
                    let locks : [Lock] = [Lock(id: "", locked: Lock.LockStatus.Locked, name: "")]
                    beforeEach {
                        lockService.allLocksHandler(locks, nil)
                    }

                    it("should set the locks value") {
                        expect(subject.locks).to(equal(locks))
                    }
                }
            }

            describe("the tableView") {
                let bulbs : [Bulb] = [Bulb(id: 3, name: "Hue Lamp 2", on: false, brightness: 194, hue: 15051,
                    saturation: 137, colorTemperature: 359, transitionTime: 10, colorMode: .colorTemperature,
                    effect: .none, reachable: true, alert: "none")]
                let locks : [Lock] = [Lock(id: "", locked: Lock.LockStatus.Locked, name: "lock")]

                var dataSource: UITableViewDataSource? = nil
                var delegate: UITableViewDelegate? = nil

                beforeEach {
                    dataSource = subject.tableView.dataSource
                    delegate = subject.tableView.delegate

                    lightsService.allBulbsHandler(bulbs, nil)
                    lockService.allLocksHandler(locks, nil)
                }

                it("should have a datasource") {
                    expect(dataSource).toNot(beNil())
                }

                it("should have a delegate") {
                    expect(delegate).toNot(beNil())
                }

                sharedExamples("a tableView section") {(sharedContext: SharedExampleContext) in
                    var sectionNumber: Int = 0

                    beforeEach {
                        sectionNumber = sharedContext()["section"] as? Int ?? 0
                    }

                    it("should title the section correctly") {
                        expect(dataSource?.respondsToSelector("tableView:titleForHeaderInSection:")).to(beTruthy())
                        let title = dataSource?.tableView?(subject.tableView,  titleForHeaderInSection: sectionNumber)

                        let expectedTitle = sharedContext()["title"] as? String
                        expect(title).to(equal(expectedTitle))
                    }

                    describe("a cell") {
                        var cell: UITableViewCell? = nil
                        var indexPath = NSIndexPath(forRow: 0, inSection: 0)

                        beforeEach {
                            indexPath = NSIndexPath(forRow: 0, inSection: sectionNumber)
                            cell = dataSource?.tableView(subject.tableView, cellForRowAtIndexPath: indexPath)
                            expect(cell).toNot(beNil())
                        }

                        it("should have the same title as the name") {
                            let expectedTitle = sharedContext()["cellTitle"] as? String
                            expect(cell?.textLabel?.text).to(equal(expectedTitle))
                        }

                        describe("tapping it") {
                            beforeEach {
                                expect(delegate?.respondsToSelector("tableView:didSelectRowAtIndexPath:")).to(beTruthy())
                                delegate?.tableView?(subject.tableView, didSelectRowAtIndexPath: indexPath)
                            }

                            it("should navigate to the desired detail screen") {
                                let expectedDetailScreen: AnyClass? = sharedContext()["cellDetailScreen"] as? AnyClass
                                expect(expectedDetailScreen).toNot(beNil())
                                NSRunLoop.currentRunLoop().runUntilDate(NSDate(timeIntervalSinceNow: 0.001))
                                if let detailScreen = expectedDetailScreen {
                                    expect(navigationController.topViewController).to(beAKindOf(detailScreen))
                                }
                            }
                        }
                    }
                }

                describe("The locks section") {
                    itBehavesLike("a tableView section") {
                        return ["section": HomeViewController.HomeViewSection.Locks.rawValue,
                                "title": "Locks",
                                "cellTitle": locks[0].name,
                                "cellDetailScreen": subject.classForCoder
                        ]
                    }

                    describe("the cell") {
                        let indexPath = NSIndexPath(forRow: 0, inSection: HomeViewController.HomeViewSection.Locks.rawValue)
                        var cell: LockTableViewCell? = nil
                        let lock = locks[0]

                        beforeEach {
                            cell = dataSource?.tableView(subject.tableView, cellForRowAtIndexPath: indexPath) as? LockTableViewCell
                        }

                        it("should be a type of LockTableViewCell") {
                            expect(cell).toNot(beNil())
                        }

                        it("should have it's switch set to the lock's switch") {
                            expect(cell?.lockStatus.on).to(beTruthy())
                        }

                        describe("tapping the switch") {
                            beforeEach {
                                cell?.lockStatus.on = false
                                cell?.lockStatus.sendActionsForControlEvents(.ValueChanged)
                            }

                            it("should unlock the lock") {
                                expect(lockService.locksUpdateHandler[lock.id]).toNot(beNil())
                                expect(lockService.locksUpdateStatus[lock.id]).to(equal(Lock.LockStatus.Unlocked))
                            }

                            it("should update the UI to show the in-progress state") {
                                let expectedColor = UIColor.blackColor().colorWithAlphaComponent(0.5)
                                expect(cell?.contentView.backgroundColor).to(equal(expectedColor))
                            }

                            context("when the request succeeds") {
                                beforeEach {
                                    if let updateHandler = lockService.locksUpdateHandler[lock.id] {
                                        let updatedLock = Lock(id: lock.id, locked: .Unlocked, name: lock.name)
                                        updateHandler(updatedLock, nil)
                                    }
                                }

                                it("should update the UI to show the not-in-progress state") {
                                    expect(cell?.contentView.backgroundColor).to(equal(UIColor.clearColor()))
                                }
                            }

                            context("when the request fails") {
                                beforeEach {
                                    if let updateHandler = lockService.locksUpdateHandler[lock.id] {
                                        let error = NSError(domain: "", code: 0, userInfo: [:])
                                        updateHandler(nil, error)
                                    }
                                }

                                it("resets the switch") {
                                    expect(cell?.lockStatus.on).to(beTruthy())
                                }

                                it("should update the UI to show the not-in-progress state") {
                                    expect(cell?.contentView.backgroundColor).to(equal(UIColor.clearColor()))
                                }
                            }
                        }
                    }
                }

                describe("The lights section") {
                    itBehavesLike("a tableView section") {
                        return ["section": HomeViewController.HomeViewSection.Lights.rawValue,
                                "title": "Lights",
                                "cellTitle": bulbs[0].name,
                                "cellDetailScreen": BulbViewController.self
                        ]
                    }

                    describe("the cell") {
                        let indexPath = NSIndexPath(forRow: 0, inSection: HomeViewController.HomeViewSection.Lights.rawValue)
                        var cell: BulbTableViewCell? = nil
                        let bulb = bulbs[0]

                        beforeEach {
                            cell = dataSource?.tableView(subject.tableView, cellForRowAtIndexPath: indexPath) as? BulbTableViewCell
                        }

                        it("should be a type of BulbTableViewCell") {
                            expect(cell).toNot(beNil())
                        }

                        it("should have it's switch set to the bulb's switch") {
                            expect(cell?.bulbStatus.on).to(beFalsy())
                        }

                        describe("tapping the switch") {
                            beforeEach {
                                cell?.bulbStatus.on = true
                                cell?.bulbStatus.sendActionsForControlEvents(.ValueChanged)
                            }

                            it("should turn on the bulb") {
                                expect(lightsService.bulbsUpdateHandler[bulb.id]).toNot(beNil())

                                expect(lightsService.bulbsUpdateStatus[bulb.id]).toNot(beNil())
                                if let updateStatusDictionary = lightsService.bulbsUpdateStatus[bulb.id] {
                                    expect(updateStatusDictionary.count).to(equal(1))
                                    expect(updateStatusDictionary["on"] as? Bool).to(beTruthy())
                                }
                            }

                            it("should update the UI to show the in-progress state") {
                                let expectedColor = UIColor.blackColor().colorWithAlphaComponent(0.5)
                                expect(cell?.contentView.backgroundColor).to(equal(expectedColor))
                            }

                            context("when the request succeeds") {
                                beforeEach {
                                    if let updateHandler = lightsService.bulbsUpdateHandler[bulb.id] {
                                        let updatedBulb = Bulb(id: 3, name: "Hue Lamp 2", on: true, brightness: 194, hue: 15051,
                                            saturation: 137, colorTemperature: 359, transitionTime: 10, colorMode: .colorTemperature,
                                            effect: .none, reachable: true, alert: "none")
                                        updateHandler(updatedBulb, nil)
                                    }
                                }

                                it("should update the UI to show the not-in-progress state") {
                                    expect(cell?.contentView.backgroundColor).to(equal(UIColor.clearColor()))
                                }
                            }

                            context("when the request fails") {
                                beforeEach {
                                    if let updateHandler = lightsService.bulbsUpdateHandler[bulb.id] {
                                        let error = NSError(domain: "", code: 0, userInfo: [:])
                                        updateHandler(nil, error)
                                    }
                                }

                                it("resets the switch") {
                                    expect(cell?.bulbStatus.on).to(beFalsy())
                                }

                                it("should update the UI to show the not-in-progress state") {
                                    expect(cell?.contentView.backgroundColor).to(equal(UIColor.clearColor()))
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}
