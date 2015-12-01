# Mole

[![Pod Version](https://img.shields.io/cocoapods/v/Mole.svg)](Mole.podspec)
[![Pod License](https://img.shields.io/cocoapods/l/Mole.svg)](LICENSE)
[![Pod Platform](https://img.shields.io/cocoapods/p/Mole.svg)](Mole.podspec)

Xcode’s UI testing is black-box by design. This works around that.

### Installation

Install with Cocoapods by adding the following to your Podfile:

```ruby
use_frameworks!

pod 'Mole'
```

Be sure to add Mole to both your app and UI test targets. Then run:

```bash
pod install
```

### Usage

Create a server class in your app target. Register methods you want your UI test target to be able to call:

```swift
import Mole

class AppServer {
    private let server = MoleServer()
    
    init() {
        server["upgraded"] = { _ in
        	return ProductController.sharedController.upgraded
        }
        
        server["setUpgraded"] = { args in
        	if let args = args as? [String: Bool], upgraded = args["upgraded"] {
            	ProductController.sharedController.upgraded = upgraded
            }
            
            return nil
        }
    }
}
```

Then create a proxy class in your UI test target, with proxy methods that correspond to the methods in your server class:

```swift
import Mole

class AppProxy {
    private let client = MoleClient()
    
    func upgraded() -> Bool {
        return client.invokeMethod("upgraded") as? Bool ?? false
    }
    
    func setUpgraded(upgraded: Bool) {
        client.invokeMethod("setUpgraded", parameters: ["upgraded": upgraded])
    }
}
```

Now you can call methods on your proxy class from your UI tests:

```swift
class Tests: XCTestCase {
	func testUpgrade() {
		let appProxy = AppProxy()
		appProxy.setUpgraded(true)
		XCTAssertTrue(appProxy.upgraded())
	}
}
```

### License

Mole is released under the MIT license. See LICENSE for details.
