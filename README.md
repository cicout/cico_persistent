# CICOPersistent
[![Carthage compatible](https://img.shields.io/badge/Carthage-compatible-4BC51D.svg?style=flat)](https://github.com/Carthage/Carthage)

CICOPersistent is a simple local storage service using codable, a new feature in Swift 4. It contains key-value file, key-value database, orm database, and key-value key chain. You can easily choose what you want. You can also use CICOAutoCodable, a simple extension for codable.

## Installation

You can simply add CICOPersistent to your `Cartfile`:  
```
github "cicout/cico_persistent"
```
Just add `CICOPersistent.framework`, `CICOAutoCodable.framework` and `FMDB.framework` to your project.

## About CICOAutoCodable
* [CICOAutoCodable](https://github.com/cicout/cico_auto_codable)

## Sample Code
### Model And JSON Definition
```swift
enum MyEnum: String, CICOAutoCodable {
    case one
    case two
}

class MyClass: CICOAutoCodable {
    var stringValue: String = "default_string"
    private(set) var dateValue: Date?
    private(set) var intValue: Int = 0
    private(set) var doubleValue: Double = 1.0
    private(set) var boolValue: Bool = false
    private(set) var enumValue: MyEnum = .one
    private(set) var urlValue: URL?
    private(set) var nextValue: MyClass?
    private(set) var arrayValue: [String]?
    private(set) var dicValue: [String: String]?
}

extension MyClass: ORMProtocol {
    static func cicoORMPrimaryKeyColumnName() -> String {
        return "stringValue"
    }
}
```
```json
{
    "stringValue": "string",
    "dateValue": 1234567890123,
    "intValue": 123,
    "doubleValue": 2.5,
    "boolValue": true,
    "enumValue": "two",
    "urlValue": "https://www.google.com",
    "nextValue": {
        "stringValue": "string",
        "intValue": 123,
        "doubleValue": 2.5,
        "boolValue": true,
        "enumValue": "two"
    },
    "arrayValue": [
              "string0",
              "string1",
              ],
    "dicValue": {
        "key0": "value0",
        "key1": "value1"
    }
}
```

### Key-Value File Service
* Initialization
```swift
let url = CICOPathAide.defaultPrivateFileURL(withSubPath: "cico_persistent_tests/kv_file")!
self.service = KVFileService.init(rootDirURL: url)
// You can also use (Public/Private/Cache/Temp)KVFileService.shared instead.
```
* Read
```swift
let key = "test_my_class"
let readValue = self.service.readObject(MyClass.self, forKey: key)
```
* Write
```swift
let key = "test_my_class"
let value = MyClass.init(jsonString: myJSONString)!
let writeResult = self.service.writeObject(value, forKey: key)
```
* Remove
```swift
let key = "test_my_class"
let removeResult = self.service.removeObject(forKey: key)
```
* Update  
It is a read-update-write sequence function during one lock.
```swift
let key = "test_my_class"
self.service
    .updateObject(MyClass.self,
                  forKey: key,
                  updateClosure: { (readObject) -> MyClass? in
                    readObject?.stringValue = "updated_string"
                    return readObject
    }) { (result) in
        print("result = \(result)")
}
```
* ClearAll
```swift
let clearResult = self.service.clearAll()
```

### URL Key-Value File Service
* Initialization
```swift
self.service = URLKVFileService.init()

let dirURL = CICOPathAide.defaultPrivateFileURL(withSubPath: "cico_persistent_tests/url_kv_file")!
let _ = CICOFileManagerAide.createDir(with: dirURL, option: false)
```
* Read
```swift
let url = CICOPathAide.defaultPrivateFileURL(withSubPath: "cico_persistent_tests/url_kv_file/test_my_class")!
let readValue = self.service.readObject(MyClass.self, fromFileURL: url)
```
* Write
```swift
let url = CICOPathAide.defaultPrivateFileURL(withSubPath: "cico_persistent_tests/url_kv_file/test_my_class")!
let value = MyClass.init(jsonString: myJSONString)!
let writeResult = self.service.writeObject(value, toFileURL: url)
```
* Remove
```swift
let url = CICOPathAide.defaultPrivateFileURL(withSubPath: "cico_persistent_tests/url_kv_file/test_my_class")!
let removeResult = self.service.removeObject(forFileURL: url)
```
* Update  
It is a read-update-write sequence function during one lock.
```swift
let url = CICOPathAide.defaultPrivateFileURL(withSubPath: "cico_persistent_tests/url_kv_file/test_my_class")!
self.service
    .updateObject(MyClass.self,
                  fromFileURL: url,
                  updateClosure: { (readObject) -> MyClass? in
                    readObject?.stringValue = "updated_string"
                    return readObject
    }) { (result) in
        print("result = \(result)")
}
```

### Key-Value DB Service
* Initialization
```swift
let url = CICOPathAide.defaultPrivateFileURL(withSubPath: "cico_persistent_tests/kv.db")!
self.service = KVDBService.init(fileURL: url)
// You can also use (Public/Private/Cache/Temp)KVDBService.shared instead.
```
* Read
```swift
let key = "test_my_class"
let readValue = self.service.readObject(MyClass.self, forKey: key)
```
* Write
```swift
let key = "test_my_class"
let value = MyClass.init(jsonString: myJSONString)!
let writeResult = self.service.writeObject(value, forKey: key)
```
* Remove
```swift
let key = "test_my_class"
let removeResult = self.service.removeObject(forKey: key)
```
* Update  
It is a read-update-write sequence function during one lock.
```swift
let key = "test_my_class"
self.service
    .updateObject(MyClass.self,
                  forKey: key,
                  updateClosure: { (readObject) -> MyClass? in
                    readObject?.stringValue = "updated_string"
                    return readObject
    }) { (result) in
        print("result = \(result)")
}
```
* ClearAll
```swift
let clearResult = self.service.clearAll()
```

### ORM DB Service
```swift
let url = CICOPathAide.defaultPrivateFileURL(withSubPath: "cico_persistent_tests/orm.db")!
self.service = ORMDBService.init(fileURL: url)
// You can also use (Public/Private/Cache/Temp)ORMDBService.shared instead.
```
* Read
```swift
let key = "string"
let readObject = self.service.readObject(ofType: MyClass.self, primaryKeyValue: key)
```
* Read Array
```
let readObjectArray = self.service.readObjectArray(ofType: MyClass.self, whereString: nil, orderByName: "stringValue", descending: false, limit: 10)
```
* Write
```swift
let value = MyClass.init(jsonString: myJSONString)!
let writeResult = self.service.writeObject(value)
```
* Write Array
```
var objectArray = [MyClass]()
for i in 0..<20 {
    let object = MyClass.init(jsonString: myJSONString)!
    object.stringValue = "string_\(i)"
    objectArray.append(object)
}
let writeResult = self.service.writeObjectArray(objectArray)
```
* Remove
```swift
let key = "string"
let removeResult = self.service.removeObject(ofType: MyClass.self, primaryKeyValue: key)
```
* Remove Object Table
```
let removeResult = self.service.removeObjectTable(ofType: MyClass.self)
```
* Update  
It is a read-update-write sequence function during one lock.
```swift
let key = "string"
self.service
    .updateObject(ofType: MyClass.self,
                  primaryKeyValue: key,
                  customTableName: nil,
                  updateClosure: { (readObject) -> MyClass? in
                    readObject?.stringValue = "updated_string"
                    return readObject
    }) { (result) in
        print("result = \(result)")
}
```
* ClearAll
```swift
let clearResult = self.service.clearAll()
```

### Key-Value KeyChain Service
* Initialization
```swift
self.service = KVKeyChainService.init(encryptionKey: "test_encryption_key")
// You can also use KVKeyChainService.defaultService instead.
```
* Read
```swift
let key = "test_my_class"
let readValue = KVKeyChainService.defaultService.readObject(MyClass.self, forKey: key)
```
* Write
```swift
let key = "test_my_class"
let value = MyClass.init(jsonString: myJSONString)!
let result = KVKeyChainService.defaultService.writeObject(value, forKey: key)
```
* Remove
```swift
let key = "test_my_class"
let removeResult = KVKeyChainService.defaultService.removeObject(forKey: key)
```
* Update  
It is a read-update-write sequence function during one lock.
```swift
let key = "test_my_class"
KVKeyChainService
    .defaultService
    .updateObject(MyClass.self,
                  forKey: key,
                  updateClosure: { (readObject) -> MyClass? in
                    readObject?.stringValue = "updated_string"
                    return readObject
    }) { (result) in
        print("result = \(result)")
}
```

### Persistent Service
It is all local storage API collection. It contains user defaults, key-value file, key-value database, orm database, and key-value key chain.

## About Sandbox
* [iOS File System Programming Guide](https://developer.apple.com/library/archive/documentation/FileManagement/Conceptual/FileSystemProgrammingGuide/FileSystemOverview/FileSystemOverview.html)  
  
For security purposes, iOS file system can be divided into four types as shown below.  

* **Public**: `"Sandbox"/Documents/`  
The contents of this directory can be made available to the user through file sharing. The files may be read/wrote/deleted by user. It should only contain imported/exported files here.  

* **Private**: `"Sandbox"/Library/`  
Any file you don’t want exposed to the user can be saved here.

* **Cache**: `"Sandbox"/Library/Caches/`  
All cache files should be placed here.

* **Temp**: `"Sandbox"/tmp/`   
Use this directory to write temporary files that do not need to persist between launches of your app. Your app should remove files from this directory when they are no longer needed.

Four shared services "**Public/Private/Cache/Temp**" have been created, you can use them directly.

## Requirements
* iOS 8.0+
* Swift 4.0+

## License
CICOPersistent is released under the MIT license. See [LICENSE](https://github.com/cicout/cico_persistent/blob/master/LICENSE) for details.

## More
Have a question? Please open an [issue](https://github.com/cicout/cico_persistent/issues/new)!
