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
        do {
            try server.start()
        } catch {}
    }
    
    public subscript(name: String) -> ((Any) throws -> Any?)? {
        get {
            return nil
        }
        set {
            if let handler = newValue {
                server["/" + name] = { request in
                    let body = request.body
                    let data = Data(bytes: body, count: body.count)
                    
                    let parameters: Any
                    do {
                        parameters = try PropertyListSerialization.propertyList(from: data, options: [], format: nil)
                    } catch {
                        return .internalServerError
                    }
                    
                    let response: Any
                    do {
                        response = try handler(parameters) ?? []
                    } catch {
                        return .internalServerError
                    }
                    
                    do {
                        let data = try PropertyListSerialization.data(fromPropertyList: response, format: .xml, options: 0)
                        var array = [UInt8](repeating: 0, count: data.count)
                        data.copyBytes(to: &array, count: data.count)
                        return .raw(200, "OK", nil, { try $0.write(array) })
                    } catch {
                        return .internalServerError
                    }
                }
            } else {
                server["/" + name] = nil
            }
        }
    }
}
