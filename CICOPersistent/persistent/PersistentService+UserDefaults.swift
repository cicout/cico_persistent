//
//  PersistentService+UserDefault.swift
//  CICOPersistent
//
//  Created by lucky.li on 2019/8/26.
//  Copyright © 2019 cico. All rights reserved.
//

import Foundation

/*************************
 * UserDefault Persistent
 *************************/

extension PersistentService {
    ///
    /// Read object from UserDefault using key;
    ///
    /// - parameter forKey: Key of the object;
    ///
    /// - returns: Read object, nil when no object for this key;
    public func readObjectFromUserDefault(forKey key: String) -> Any? {
        return UserDefaults.standard.object(forKey: key)
    }

    /// Read object from UserDefault using key;
    ///
    /// - parameter objectType: Type of the object;
    /// - parameter forKey: Key of the object;
    ///
    /// - returns: Read object, nil when no object for this key;
    ///
    /// - see: UserDefaults.standard.object(forKey:);
    public func readValueFromUserDefault<T>(_ objectType: T.Type, forKey key: String) -> T? {
        if let value = UserDefaults.standard.object(forKey: key) as? T {
            return value
        } else {
            return nil
        }
    }

    /// Write value into UserDefault using key;
    ///
    /// - parameter value: The value will be saved in UserDefault;
    /// - parameter forKey: Key of the object;
    ///
    /// - see: UserDefaults.standard.set(_:forKey:);
    public func writeUserDefaultValue(_ value: Any?, forKey key: String) {
        UserDefaults.standard.set(value, forKey: key)
    }

    /// Remove object from UserDefault using key;
    ///
    /// - parameter forKey: Key of the object;
    ///
    /// - see: UserDefaults.standard.removeObject(forKey:);
    public func removeUserDefaultValue(forKey key: String) {
        UserDefaults.standard.removeObject(forKey: key)
    }

    /// Synchronize for UserDefaults;
    ///
    /// - see: UserDefaults.standard.synchronize();
    public func synchronizeUserDefault() -> Bool {
        return UserDefaults.standard.synchronize()
    }
}
