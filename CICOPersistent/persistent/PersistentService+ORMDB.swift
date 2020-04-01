//
//  PersistentService+ORMDB.swift
//  CICOPersistent
//
//  Created by lucky.li on 2019/8/26.
//  Copyright © 2019 cico. All rights reserved.
//

import Foundation

/**********************************
 * Codable ORM Database Persistent
 **********************************/

extension PersistentService {
    ///
    /// Read object from database of ORMDBService using primary key;
    ///
    /// - parameter objectType: Type of the object, it must conform to codable protocol and ORMProtocol;
    /// - parameter primaryKeyValue: Primary key value of the object in database, it must conform to codable protocol;
    /// - parameter customTableName: One class or struct can be saved in different tables,
    ///             you can define your custom table name here;
    ///             It will use default table name according to the class or struct name when passing nil;
    ///
    /// - returns: Read object, nil when no object for this primary key;
    ///
    /// - see: ORMDBService.readObject(ofType:primaryKeyValue:customTableName:)
    open func readORMDBObject<T: ORMCodableProtocol>(ofType objectType: T.Type,
                                                     primaryKeyValue: Codable,
                                                     customTableName: String? = nil) -> T? {
        return self.ormDBService.readObject(ofType: objectType,
                                            primaryKeyValue: primaryKeyValue,
                                            customTableName: customTableName)
    }

    /// Read object array from database of ORMDBService using SQL;
    ///
    /// SQL: SELECT * FROM "TableName" WHERE "whereString" ORDER BY "orderByName" DESC/ASC LIMIT "limit";
    ///
    /// - parameter objectType: Type of the object, it must conform to codable protocol and ORMProtocol;
    /// - parameter whereString: Where string for SQL;
    /// - parameter orderByName: Order by name for SQL;
    /// - parameter customTableName: One class or struct can be saved in different tables,
    ///             you can define your custom table name here;
    ///             It will use default table name according to the class or struct name when passing nil;
    ///
    /// - returns: Read object, nil when no object for this primary key;
    ///
    /// - see: ORMDBService.readObjectArray(ofType:whereString:orderByName:descending:limit:customTableName:)
    open func readORMDBObjectArray<T: ORMCodableProtocol>(ofType objectType: T.Type,
                                                          whereString: String? = nil,
                                                          orderByName: String? = nil,
                                                          descending: Bool = true,
                                                          limit: Int? = nil,
                                                          customTableName: String? = nil) -> [T]? {
        return self.ormDBService.readObjectArray(ofType: objectType,
                                                 whereString: whereString,
                                                 orderByName: orderByName,
                                                 descending: descending,
                                                 limit: limit,
                                                 customTableName: customTableName)
    }

    /// Write object into database of ORMDBService using primary key;
    ///
    /// Add when it does not exist, update when it exists;
    ///
    /// - parameter object: The object will be saved in database, it must conform to codable protocol and ORMProtocol;
    /// - parameter customTableName: One class or struct can be saved in different tables,
    ///             you can define your custom table name here;
    ///             It will use default table name according to the class or struct name when passing nil;
    ///
    /// - returns: Write result;
    ///
    /// - see: ORMDBService.writeObject(_:customTableName:)
    open func writeORMDBObject<T: ORMCodableProtocol>(_ object: T, customTableName: String? = nil) -> Bool {
        return self.ormDBService.writeObject(object, customTableName: customTableName)
    }

    /// Write object array into database of ORMDBService using primary key in one transaction;
    ///
    /// Add when it does not exist, update when it exists;
    ///
    /// - parameter objectArray: The object array will be saved in database,
    ///             it must conform to codable protocol and ORMProtocol;
    /// - parameter customTableName: One class or struct can be saved in different tables,
    ///             you can define your custom table name here;
    ///             It will use default table name according to the class or struct name when passing nil;
    ///
    /// - returns: Write result;
    ///
    /// - see: ORMDBService.writeObjectArray(_:customTableName:)
    open func writeORMDBObjectArray<T: ORMCodableProtocol>(_ objectArray: [T], customTableName: String? = nil) -> Bool {
        return self.ormDBService.writeObjectArray(objectArray, customTableName: customTableName)
    }

    /// Update object in database of ORMDBService using primary key;
    ///
    /// Read the existing object, then call the "updateClosure", and write the object returned by "updateClosure";
    /// It won't update when "updateClosure" returns nil;
    ///
    /// - parameter objectType: Type of the object, it must conform to codable protocol;
    /// - parameter primaryKeyValue: Primary key value of the object in database, it must conform to codable protocol;
    /// - parameter customTableName: One class or struct can be saved in different tables,
    ///             you can define your custom table name here;
    ///             It will use default table name according to the class or struct name when passing nil;
    /// - parameter updateClosure: It will be called after reading object from database,
    ///             the read object will be passed as parameter, you can return a new value to update in database;
    ///             It won't be updated to database when you return nil by this closure;
    /// - parameter completionClosure: It will be called when completed, passing update result as parameter;
    ///
    /// - see: ORMDBService.updateObject(ofType:primaryKeyValue:customTableName:updateClosure:completionClosure:)
    open func updateORMDBObject<T: ORMCodableProtocol>(ofType objectType: T.Type,
                                                       primaryKeyValue: Codable,
                                                       customTableName: String? = nil,
                                                       updateClosure: (T?) -> T?,
                                                       completionClosure: ((Bool) -> Void)? = nil) {
        return self.ormDBService.updateObject(ofType: objectType,
                                              primaryKeyValue: primaryKeyValue,
                                              customTableName: customTableName,
                                              updateClosure: updateClosure,
                                              completionClosure: completionClosure)
    }

    /// Remove object from database of ORMDBService using primary key;
    ///
    /// - parameter objectType: Type of the object, it must conform to codable protocol;
    /// - parameter primaryKeyValue: Primary key value of the object in database, it must conform to codable protocol;
    /// - parameter customTableName: One class or struct can be saved in different tables,
    ///             you can define your custom table name here;
    ///             It will use default table name according to the class or struct name when passing nil;
    ///
    /// - returns: Remove result;
    ///
    /// - see: ORMDBService.removeObject(ofType:primaryKeyValue:customTableName: customTableName)
    open func removeORMDBObject<T: ORMCodableProtocol>(ofType objectType: T.Type,
                                                       primaryKeyValue: Codable,
                                                       customTableName: String? = nil) -> Bool {
        return self.ormDBService.removeObject(ofType: objectType,
                                              primaryKeyValue: primaryKeyValue,
                                              customTableName: customTableName)
    }

    /// Remove the whole table from database of ORMDBService by table name;
    ///
    /// - parameter objectType: Type of the object, it must conform to codable protocol;
    /// - parameter customTableName: One class or struct can be saved in different tables,
    ///             you can define your custom table name here;
    ///             It will use default table name according to the class or struct name when passing nil;
    ///
    /// - returns: Remove result;
    ///
    /// - see: ORMDBService.removeObjectTable(ofType:customTableName:)
    open func removeORMDBObjectTable<T: ORMCodableProtocol>(ofType objectType: T.Type,
                                                            customTableName: String? = nil) -> Bool {
        return self.ormDBService.removeObjectTable(ofType: objectType, customTableName: customTableName)
    }

    /// Remove all tables from database of ORMDBService;
    ///
    /// - returns: Remove result;
    ///
    /// - see: ORMDBService.clearAll()
    open func clearAllORMDB() -> Bool {
        return self.ormDBService.clearAll()
    }
}
