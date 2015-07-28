import Quick
import Nimble
import ApartKit

class LockSpec: QuickSpec {
    override func spec() {
        it("inits from json") {
            let jsonString = "{\"uuid\":\"1234567890abcdef\",\"locked\":true}"

            let dict: AnyObject?
            do {
                dict = try NSJSONSerialization.JSONObjectWithData(NSString(string: jsonString).dataUsingEncoding(NSUTF8StringEncoding)!, options: [])
            } catch _ {
                dict = nil
            }
            expect(dict).toNot(beNil())

            if let obj = dict as? [String: AnyObject] {
                let subject = Lock(json: obj)
                expect(subject).toNot(beNil())

                expect(subject.id).to(equal("1234567890abcdef"))
                expect(subject.locked).to(beTruthy())
            }
        }
    }
}
