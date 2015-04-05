import Quick
import Nimble

class BulbSpec: QuickSpec {
    override func spec() {

        it("Initing from json") {
            let jsonString = "{\"id\":3,\"changes\":{},\"name\":\"Hue Lamp 2\",\"on\":false,\"bri\":194,\"hue\":15051,\"sat\":137,\"xy\":[0.4,0.4],\"ct\":359,\"transitiontime\":10,\"colormode\":\"ct\",\"effect\":\"none\",\"reachable\":true,\"alert\":\"none\"}"

            let dict: AnyObject? = NSJSONSerialization.JSONObjectWithData(NSString(string: jsonString).dataUsingEncoding(NSUTF8StringEncoding)!, options: .allZeros, error: nil)
            expect(dict).toNot(beNil())

            if let obj = dict as? [String: AnyObject] {
                let subject = Bulb(json: obj)
                expect(subject).toNot(beNil())

                let expected = Bulb(id: 3, name: "Hue Lamp 2", on: false, brightness: 194, hue: 15051,
                                    saturation: 137, colorTemperature: 359, transitionTime: 10, colorMode: .colorTemperature,
                                    effect: .none, reachable: true, alert: "none")

                if let sub = subject {
                    expect(sub).to(equal(expected))
                }
            }
        }
    }
}
