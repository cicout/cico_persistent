# CICOPersistent
![Swift5 compatible][Swift5Badge] [![CocoaPods][PodBadge]][PodLink] [![SPM compatible][SPMBadge]][SPMLink] [![Carthage compatible][CartagheBadge]][CarthageLink] [![License MIT][MITBadge]][MITLink]

CICOPersistent is a simple local storage service using codable. It contains orm database, key-value file, key-value database and key-value key chain. You can easily choose what you want. You can also use CICOAutoCodable, a simple extension for codable.

## Installation

### CocoaPod

You can simply add CICOPersistent to your `Podfile`:

```
pod "CICOPersistent"
```

Use following code instead if you want to use CICOPersistent with SQLCipher:

```
pod "CICOPersistent/SQLCipher"
```

### Carthage

You can simply add CICOPersistent to your `Cartfile`:  

```
github "cicout/cico_persistent"
```

Just add `CICOPersistent.framework`, `CICOAutoCodable.framework` and `FMDB.framework` to your project.

## Sample code

### Model

```swift
enum MyEnum: String, Codable {
    case one
    case two
}

struct MyStruct: Codable {
    var stringValue: String = "default_string"
    var dateValue: Date?
    var intValue: Int = 0
    var doubleValue: Double = 1.0
    var boolValue: Bool = false
    var enumValue: MyEnum = .one
    var urlValue: URL?
    var arrayValue: [String]?
    var dicValue: [String: String]?
}

extension MyStruct: ORMProtocol {
    static func ormPrimaryKeyColumnName() -> CompositeType<String> {
        return .single("stringValue")
    }
}
```

### Json

```json
{
    "stringValue": "string",
    "dateValue": 1234567890123,
    "intValue": 123,
    "doubleValue": 2.5,
    "boolValue": true,
    "enumValue": "two",
    "urlValue": "https://www.google.com",
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

### ORMDBService

* Initialization

```swift
let url = CICOPathAide.defaultPrivateFileURL(withSubPath: "cico_persistent_tests/orm.db")!
self.service = ORMDBService.init(fileURL: url)
```

* Read

```swift
let readObject = self.service.readObject(ofType: MyStruct.self, primaryKeyValue: .single("default_string"))
```

* Read array

```
let readObjectArray = self.service.readObjectArray(ofType: MyStruct.self, whereString: nil, orderByName: "stringValue", descending: false, limit: 10)
```

* Write

```swift
let value = MyStruct.init(jsonString: myJSONString)!
let writeResult = self.service.writeObject(value)
```

* Write array

```
var objectArray = [MyStruct]()
for i in 0..<20 {
    let object = MyStruct.init(jsonString: myJSONString)!
    object.stringValue = "string_\(i)"
    objectArray.append(object)
}
let writeResult = self.service.writeObjectArray(objectArray)
```

* Remove

```swift
let removeResult = self.service.removeObject(ofType: MyStruct.self, primaryKeyValue: .single("default_string"))
```

* Remove object table

```
let removeResult = self.service.removeObjectTable(ofType: MyStruct.self)
```

* Update  

It is a read-update-write sequence function during one lock.

```swift
self.service
    .updateObject(ofType: MyStruct.self,
                  primaryKeyValue: .single("default_string"),
                  customTableName: nil,
                  updateClosure: { (readObject) -> MyStruct? in
                    var newObject = readObject
                    newObject?.stringValue = "updated_string"
                    return newObject
    }) { (result) in
        print("result = \(result)")
}
```

* ClearAll

```swift
let clearResult = self.service.clearAll()
```

### KVFileService

* Initialization

```swift
let url = CICOPathAide.defaultPrivateFileURL(withSubPath: "cico_persistent_tests/kv_file")!
self.service = KVFileService.init(rootDirURL: url)
```

* Read

```swift
let key = "test_my_struct"
let readValue = self.service.readObject(MyStruct.self, forKey: key)
```

* Write

```swift
let key = "test_my_struct"
let value = MyStruct.init(jsonString: myJSONString)!
let writeResult = self.service.writeObject(value, forKey: key)
```

* Remove

```swift
let key = "test_my_struct"
let removeResult = self.service.removeObject(forKey: key)
```

* Update  

```swift
let key = "test_my_struct"
self.service
    .updateObject(MyStruct.self,
                  forKey: key,
                  updateClosure: { (readObject) -> MyStruct? in
                    var newObject = readObject
                    newObject?.stringValue = "updated_string"
                    return newObject
    }) { (result) in
        print("result = \(result)")
}
```

* ClearAll

```swift
let clearResult = self.service.clearAll()
```

### URLKVFileService

* Initialization

```swift
self.service = URLKVFileService.init()
let dirURL = CICOPathAide.defaultPrivateFileURL(withSubPath: "cico_persistent_tests/url_kv_file")!
let _ = CICOFileManagerAide.createDir(with: dirURL, option: false)
```

* Read

```swift
let url = CICOPathAide.defaultPrivateFileURL(withSubPath: "cico_persistent_tests/url_kv_file/test_my_struct")!
let readValue = self.service.readObject(MyStruct.self, fromFileURL: url)
```

* Write

```swift
let url = CICOPathAide.defaultPrivateFileURL(withSubPath: "cico_persistent_tests/url_kv_file/test_my_struct")!
let value = MyStruct.init(jsonString: myJSONString)!
let writeResult = self.service.writeObject(value, toFileURL: url)
```

* Remove

```swift
let url = CICOPathAide.defaultPrivateFileURL(withSubPath: "cico_persistent_tests/url_kv_file/test_my_struct")!
let removeResult = self.service.removeObject(forFileURL: url)
```

* Update

```swift
let url = CICOPathAide.defaultPrivateFileURL(withSubPath: "cico_persistent_tests/url_kv_file/test_my_struct")!
self.service
    .updateObject(MyStruct.self,
                  fromFileURL: url,
                  updateClosure: { (readObject) -> MyStruct? in
                    var newObject = readObject
                    newObject?.stringValue = "updated_string"
                    return newObject
    }) { (result) in
        print("result = \(result)")
}
```

### KVDBService

* Initialization

```swift
let url = CICOPathAide.defaultPrivateFileURL(withSubPath: "cico_persistent_tests/kv.db")!
self.service = KVDBService.init(fileURL: url)
```

* Read

```swift
let key = "test_my_struct"
let readValue = self.service.readObject(MyStruct.self, forKey: key)
```

* Write

```swift
let key = "test_my_struct"
let value = MyStruct.init(jsonString: myJSONString)!
let writeResult = self.service.writeObject(value, forKey: key)
```

* Remove

```swift
let key = "test_my_struct"
let removeResult = self.service.removeObject(forKey: key)
```

* Update  

```swift
let key = "test_my_struct"
self.service
    .updateObject(MyStruct.self,
                  forKey: key,
                  updateClosure: { (readObject) -> MyStruct? in
                    var newObject = readObject
                    newObject?.stringValue = "updated_string"
                    return newObject
    }) { (result) in
        print("result = \(result)")
}
```

* ClearAll

```swift
let clearResult = self.service.clearAll()
```

### KVKeyChainService

* Initialization

```swift
self.service = KVKeyChainService.init(encryptionKey: "test_encryption_key")
// You can also use KVKeyChainService.defaultService instead.
```

* Read

```swift
let key = "test_my_struct"
let readValue = KVKeyChainService.defaultService.readObject(MyStruct.self, forKey: key)
```

* Write

```swift
let key = "test_my_struct"
let value = MyStruct.init(jsonString: myJSONString)!
let result = KVKeyChainService.defaultService.writeObject(value, forKey: key)
```

* Remove

```swift
let key = "test_my_struct"
let removeResult = KVKeyChainService.defaultService.removeObject(forKey: key)
```

* Update  

```swift
let key = "test_my_struct"
KVKeyChainService
    .defaultService
    .updateObject(MyStruct.self,
                  forKey: key,
                  updateClosure: { (readObject) -> MyStruct? in
                    var newObject = readObject
                    newObject?.stringValue = "updated_string"
                    return newObject
    }) { (result) in
        print("result = \(result)")
}
```

### PersistentService

It is all local storage API collection. It contains user defaults, key-value file, key-value database, orm database, and key-value key chain.

## About sandbox

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

## About CICOAutoCodable

* [CICOAutoCodable](https://github.com/cicout/cico_auto_codable)

## Requirements

* iOS 12.0+
* Swift 5.0+

## License

CICOPersistent is released under the MIT license. See [LICENSE](https://github.com/cicout/cico_persistent/blob/master/LICENSE) for details.

## More

Have a question? Please open an [issue](https://github.com/cicout/cico_persistent/issues/new)!

[Swift5Badge]: https://img.shields.io/badge/swift-5-orange.svg?style=flat
[Swift5Link]: https://developer.apple.com/swift/

[PodBadge]: https://img.shields.io/cocoapods/v/CICOPersistent.svg?style=flat
[PodLink]: http://cocoapods.org/pods/CICOPersistent

[SPMBadge]: https://img.shields.io/badge/Swift%20Package%20Manager-compatible-brightgreen.svg
[SPMLink]: https://github.com/swiftlang/swift-package-manager

[CartagheBadge]: https://img.shields.io/badge/Carthage-compatible-4BC51D.svg?style=flat
[CarthageLink]: https://github.com/Carthage/Carthage

[MITBadge]: https://img.shields.io/badge/License-MIT-blue.svg?style=flat
[MITLink]: https://github.com/cicout/cico_persistent/blob/develop/LICENSE