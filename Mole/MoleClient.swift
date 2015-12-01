//
// Copyright (c) 2015 Hilton Campbell
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.
//

import Foundation

public class MoleClient {
    
    public init() {}
    
    public func invokeMethod(name: String = __FUNCTION__, parameters: AnyObject = []) -> AnyObject? {
        let urlComponents = NSURLComponents()
        urlComponents.scheme = "http"
        urlComponents.host = "localhost"
        urlComponents.port = 8080
        urlComponents.path = "/" + name
        
        if let url = urlComponents.URL {
            let body: NSData
            do {
                body = try NSPropertyListSerialization.dataWithPropertyList(parameters, format: .XMLFormat_v1_0, options: 0)
            } catch let error as NSError {
                fatalError("Failed to serialize arguments to test bridge: \(error)")
            }
            
            let request = NSMutableURLRequest(URL: url)
            request.HTTPMethod = "POST"
            request.HTTPBody = body
            
            var result: AnyObject?
            
            let semaphore = dispatch_semaphore_create(0)
            
            NSURLSession.sharedSession().dataTaskWithRequest(request) { data, _, error in
                if let error = error {
                    fatalError("Received error from test bridge: \(error)")
                } else if let data = data {
                    do {
                        result = try NSPropertyListSerialization.propertyListWithData(data, options: [], format: nil)
                    } catch let error as NSError {
                        fatalError("Failed to deserialize response from test bridge: \(error)")
                    }
                }
                
                dispatch_semaphore_signal(semaphore)
            }.resume()
            
            dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER)
            
            return result
        } else {
            fatalError("Failed to construct URL to test bridge")
        }
    }
    
}
