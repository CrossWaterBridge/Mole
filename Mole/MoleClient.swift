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
    
    @discardableResult
    public func invokeMethod(_ name: String = #function, parameters: Any = []) -> Any? {
        var urlComponents = URLComponents()
        urlComponents.scheme = "http"
        urlComponents.host = "localhost"
        urlComponents.port = 8080
        urlComponents.path = "/" + name
        
        if let url = urlComponents.url {
            let body: Data
            do {
                body = try PropertyListSerialization.data(fromPropertyList: parameters, format: .xml, options: 0)
            } catch let error as NSError {
                fatalError("Failed to serialize arguments to test bridge: \(error)")
            }
            
            var request = URLRequest(url: url)
            request.httpMethod = "POST"
            request.httpBody = body
            
            var result: Any?
            
            let semaphore = DispatchSemaphore(value: 0)
            
            URLSession.shared.dataTask(with: request, completionHandler: { data, _, error in
                if let error = error {
                    fatalError("Received error from test bridge: \(error)")
                } else if let data = data {
                    do {
                        result = try PropertyListSerialization.propertyList(from: data, options: [], format: nil)
                    } catch let error as NSError {
                        fatalError("Failed to deserialize response from test bridge: \(error)")
                    }
                }
                
                semaphore.signal()
            }).resume()
            
            _ = semaphore.wait(timeout: DispatchTime.distantFuture)
            
            return result
        } else {
            fatalError("Failed to construct URL to test bridge")
        }
    }
}
