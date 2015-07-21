import Foundation

class FakeDataTask: NSURLSessionDataTask {
    override func resume() {

    }
}

class FakeURLSession: NSURLSession {
    var lastURLRequest: NSURLRequest? = nil
    var lastCompletionHandler: (NSData?, NSURLResponse?, NSError?) -> (Void) = {_, _, _ in }
    override func dataTaskWithRequest(request: NSURLRequest, completionHandler: (NSData?, NSURLResponse?, NSError?) -> Void) -> NSURLSessionDataTask {
        lastURLRequest = request
        lastCompletionHandler = completionHandler
        return FakeDataTask()
    }
}
