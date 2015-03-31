import Quick
import Nimble
import Ra
import Alamofire

class LightsServiceSpec: QuickSpec {
    override func spec() {
        var subject : LightsService! = nil
        var injector : Ra.Injector! = nil

        beforeEach {
            injector = Ra.Injector()

            SpecApplicationModule().configureInjector(injector)

            subject = injector.create(kLightsService) as! LightsService
        }

        describe("Getting all the bulbs") {
            it("return all the bulbs") {
                subject.allBulbs {(result, error) in
                    expect(error).to(beNil())
                    expect(result).toNot(beNil())
                }
            }

            it("should notify the user on error") {
            }
        }
    }
}
