//
//  CICOKVKeyChainService.swift
//  CICOPersistent
//
//  Created by lucky.li on 2018/7/27.
//  Copyright © 2018 cico. All rights reserved.
//

import Foundation
import CICOAutoCodable

private let kGenericKey = "cico_kv_generic_key"
private let kAccountKey = "cico_kv_account_key"

public class CICOKVKeyChainService {
    let keyChainService: CICOKeyChainService
    let lock = NSLock()
    
    deinit {
        print("\(self) deinit")
    }
    
    init(group: String) {
        self.keyChainService = CICOKeyChainService.init(group: group)
    }
    
    public func readObject<T: Codable>(_ type: T.Type, forKey userKey: String) -> T? {
        guard let jsonKey = self.jsonKey(forUserKey: userKey) else {
            return nil
        }
        
        self.lock.lock()
        defer {
            self.lock.unlock()
        }
        
        guard let jsonData = self.keyChainService.query(genericKey: kGenericKey, accountKey: kAccountKey, serviceKey: jsonKey) else {
            return nil
        }
        
        return T.init(jsonData: jsonData)
    }
    
    public func writeObject<T: Codable>(_ object: T, forKey userKey: String) -> Bool {
        guard let jsonKey = self.jsonKey(forUserKey: userKey) else {
            return false
        }
        
        guard let jsonData = object.toJSONData() else {
            return false
        }
        
        self.lock.lock()
        defer {
            self.lock.unlock()
        }
        
        if let _ = self.keyChainService.query(genericKey: kGenericKey, accountKey: kAccountKey, serviceKey: jsonKey) {
            return self.keyChainService.update(data: jsonData, genericKey: kGenericKey, accountKey: kAccountKey, serviceKey: jsonKey)
        } else {
            return self.keyChainService.add(data: jsonData, genericKey: kGenericKey, accountKey: kAccountKey, serviceKey: jsonKey)
        }
    }
    
    public func updateObject<T: Codable>(_ type: T.Type,
                                           forKey userKey: String,
                                           updateClosure: (T?) -> T?,
                                           completionClosure: ((Bool) -> Void)? = nil) {
        guard let jsonKey = self.jsonKey(forUserKey: userKey) else {
            completionClosure?(false)
            return
        }
        
        self.lock.lock()
        defer {
            self.lock.unlock()
        }
        
        var object: T? = nil
        var exist = false
        if let jsonData = self.keyChainService.query(genericKey: kGenericKey, accountKey: kAccountKey, serviceKey: jsonKey) {
            exist = true
            object = T.init(jsonData: jsonData)
        }
        
        guard let newObject = updateClosure(object) else {
            completionClosure?(true)
            return
        }
        
        guard let newJSONData = newObject.toJSONData() else {
            completionClosure?(false)
            return
        }
        
        if exist {
            let result = self.keyChainService.update(data: newJSONData, genericKey: kGenericKey, accountKey: kAccountKey, serviceKey: jsonKey)
            completionClosure?(result)
        } else {
            let result = self.keyChainService.add(data: newJSONData, genericKey: kGenericKey, accountKey: kAccountKey, serviceKey: jsonKey)
            completionClosure?(result)
        }
    }
    
    public func removeObject(forKey userKey: String) -> Bool {
        guard let jsonKey = self.jsonKey(forUserKey: userKey) else {
            return false
        }

        return self.keyChainService.delete(genericKey: kGenericKey, accountKey: kAccountKey, serviceKey: jsonKey)
    }

    private func jsonKey(forUserKey userKey: String) -> String? {
        guard userKey.count > 0 else {
            return nil
        }
        
        return CICOSecurityAide.md5HashString(with: userKey)
    }
}
