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
import Swifter

public class MoleServer {
    
    private let server = HttpServer()
    
    public init() {
        server.start()
    }
    
    public subscript(name: String) -> ((AnyObject) throws -> AnyObject?)? {
        get {
            return nil
        }
        set {
            if let handler = newValue {
                server["/" + name] = { request in
                    let data = request.body?.dataUsingEncoding(NSUTF8StringEncoding)
                    
                    let parameters: AnyObject
                    if let data = data {
                        do {
                            parameters = try NSPropertyListSerialization.propertyListWithData(data, options: [], format: nil)
                        } catch {
                            return HttpResponse.InternalServerError
                        }
                    } else {
                        parameters = []
                    }
                    
                    let response: AnyObject
                    do {
                        response = try handler(parameters) ?? []
                    } catch {
                        return HttpResponse.InternalServerError
                    }
                    
                    do {
                        return HttpResponse.RAW(200, "OK", nil, try NSPropertyListSerialization.dataWithPropertyList(response, format: .XMLFormat_v1_0, options: 0))
                    } catch {
                        return HttpResponse.InternalServerError
                    }
                }
            } else {
                server["/" + name] = nil
            }
        }
    }
    
}