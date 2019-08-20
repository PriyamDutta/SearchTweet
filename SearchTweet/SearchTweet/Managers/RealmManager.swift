//
//  RealmManager.swift
//  SearchTweet
//
//  Created by Priyam Dutta on 18/08/19.
//  Copyright © 2019 Priyam Dutta. All rights reserved.
//

import Foundation
import RealmSwift

protocol RealmDataHandleProtocol: AnyObject {
    func writeData<T: Object>(_ objects: [T])
    func readData<T: Object>(_ type: T.Type, predicate: NSPredicate, orderBy: (keyPath: String, isAsc: Bool)) -> [T]
    static func deleteAllData<T: Object>(_ type: T.Type, predicate: NSPredicate) -> Bool
}

final class RealmManager: RealmDataHandleProtocol {
    
    func configureRealm() {
        let config = Realm.Configuration(
            schemaVersion: 0,
            migrationBlock: { migration, oldSchemaVersion in
                if (oldSchemaVersion < 1) {
                }
        })
        Realm.Configuration.defaultConfiguration = config
        _ = try? Realm()
    }
    
    
    func writeData<T>(_ objects: [T]) where T : Object {
        if let realm = try? Realm() {
            try? realm.write {
                realm.add(objects, update: true)
            }
        }
    }
    
    func readData<T>(_ type: T.Type, predicate: NSPredicate, orderBy: (keyPath: String, isAsc: Bool)) -> [T] where T : Object {
        if let realm = try? Realm() {
            let objects = realm.objects(T.self).sorted(byKeyPath: orderBy.keyPath, ascending: orderBy.isAsc)
            return Array(objects)
        }
        return []
    }
    
    @discardableResult
    static func deleteAllData<T>(_ type: T.Type, predicate: NSPredicate) -> Bool where T : Object {
        if let realm = try? Realm() {
            let fetchedObjects = realm.objects(T.self).filter(predicate)
            print("Deleted: \(fetchedObjects.count)")
            try? realm.write {
                realm.delete(fetchedObjects)
            }
        }
        return true
    }
}
