import Quick
import Nimble
import ApartKit

class StringExtensionsSpec: QuickSpec {
    override func spec() {
        describe("desnake") {
            it("does not crash if self is empty") {
                let heyCompilerWhyYouSoCrashy: String = ""
                expect(heyCompilerWhyYouSoCrashy.desnake) == ""
            }

            it("capitalizes the first letter in the string") {
                let hello = "hello"
                expect(hello.desnake) == "Hello"
            }

            it("replaces all '_' with ' '") {
                let sentence = "this_is_a_sentence"
                expect(sentence.desnake) == "This is a sentence"
            }
        }
    }
}
