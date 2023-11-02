//
//  DataCache.swift
//  beta2
//
//  Created by Oskar Almå on 2023-11-02.
//



import Foundation

class DataCache<Key: Hashable, Value> {
    private let cache = NSCache<WrappedKey, Entry>()

    func insert(_ value: Value, forKey key: Key) {
        let entry = Entry(value: value)
        cache.setObject(entry, forKey: WrappedKey(key))
    }

    func value(forKey key: Key) -> Value? {
        let entry = cache.object(forKey: WrappedKey(key))
        return entry?.value
    }

    func removeValue(forKey key: Key) {
        cache.removeObject(forKey: WrappedKey(key))
    }
}

extension DataCache {
    private final class WrappedKey: NSObject {
        let key: Key

        init(_ key: Key) { self.key = key }

        override var hash: Int { return key.hashValue }

        override func isEqual(_ object: Any?) -> Bool {
            guard let value = object as? WrappedKey else {
                return false
            }

            return value.key == key
        }
    }
}

extension DataCache {
    private final class Entry {
        let value: Value

        init(value: Value) {
            self.value = value
        }
    }
}
