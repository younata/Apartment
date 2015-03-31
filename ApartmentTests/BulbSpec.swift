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

                if let sub = subject {
                    expect(sub.id).to(equal(3))
                    expect(sub.name).to(equal("Hue Lamp 2"))
                    expect(sub.on).to(beFalsy())
                    expect(sub.brightness).to(equal(194))
                    expect(sub.hue).to(equal(15051))
                    expect(sub.saturation).to(equal(137))
                    expect(sub.colorTemperature).to(equal(359))
                    expect(sub.transitionTime).to(equal(10))
                    expect(sub.colorMode).to(equal("ct"))
                    expect(sub.effect).to(equal("none"))
                    expect(sub.reachable).to(beTruthy())
                    expect(sub.alert).to(equal("none"))
                }
            }
        }
    }
}
