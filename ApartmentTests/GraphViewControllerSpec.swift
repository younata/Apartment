import Quick
import Nimble
import ApartKit
import Apartment
import Ra

class GraphViewControllerSpec: QuickSpec {
    override func spec() {
        var subject: GraphViewController!
        var homeRepository: FakeHomeRepository!
        var injector: Injector!

        let entity = State(attributes: ["friendly_name": "test"], entityId: "sensor.weather_temperature", lastChanged: NSDate(), lastUpdated: NSDate(), state: "51")

        beforeEach {
            injector = Injector()
            homeRepository = FakeHomeRepository()
            injector.bind(HomeRepository.self, toInstance: homeRepository)

            subject = injector.create(GraphViewController)
            subject.view.layoutIfNeeded()

            subject.entity = entity
        }

        it("sets the title to the entity's displayName") {
            expect(subject.title) == "test"
        }

        it("makes a request for the entity's history") {
            expect(homeRepository.historyState) == entity
            expect(homeRepository.historyCallback).toNot(beNil())
        }

        func historyWithData(data: [String]) -> [State] {
            var ret = [State]()
            for (idx, value) in data.enumerate() {
                let state = State(attributes: [:], entityId: entity.entityId, lastChanged: NSDate(timeIntervalSinceNow: Double(idx+1) * 100.0), lastUpdated: NSDate(timeIntervalSinceNow: Double(idx+1) * 100.0), state: value)
                ret.append(state)
            }
            return ret
        }

        context("when the request comes back") {
            context("with numerical sensor data") {
                let states = historyWithData([
                    "47",
                    "50",
                    "49",
                    "52"
                ])

                beforeEach {
                    homeRepository.historyCallback?(states)
                }

                // displays a graph
            }

            context("with other kinds of sensor data") {
                let states = historyWithData([
                    "on",
                    "off",
                    "on",
                    "off"
                ])

                beforeEach {
                    homeRepository.historyCallback?(states)
                }

                // displays something else?
            }
        }

        context("when the request fails") {
            beforeEach {
                homeRepository.historyCallback?([])
            }

            it("informs the user that it was unable to retrieve the history") {
                expect(subject.presentedViewController).to(beAKindOf(UIAlertController.self))

                if let alert = subject.presentedViewController as? UIAlertController {
                    expect(alert.title) == "Unable to retrieve history"
                    expect(alert.actions.count) == 2

                    if let tryAgain = alert.actions.first {
                        expect(tryAgain.title) == "Try again"
                        expect(tryAgain.style) == UIAlertActionStyle.Default

                        homeRepository.historyCallback = nil
                        homeRepository.historyState = nil

                        tryAgain.handler()(tryAgain)

                        expect(subject.presentedViewController).to(beNil())
                        expect(homeRepository.historyState) == entity
                        expect(homeRepository.historyCallback).toNot(beNil())
                    }
                    if let dismiss = alert.actions.last {
                        expect(dismiss.title) == "Oh well"
                        expect(dismiss.style) == UIAlertActionStyle.Cancel

                        homeRepository.historyCallback = nil
                        homeRepository.historyState = nil

                        dismiss.handler()(dismiss)

                        expect(subject.presentedViewController).to(beNil())

                        expect(homeRepository.historyState).to(beNil())
                        expect(homeRepository.historyCallback).to(beNil())
                    }
                }
            }
        }
    }
}
