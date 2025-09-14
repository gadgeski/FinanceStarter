//
//  CacheStore.swift
//  FinanceStarter
//
//  Created by Dev Tech on 2025/09/10.
//

// Data/CacheStore.swift  // <-- [REPLACED]
import Foundation

// キャッシュ操作の抽象（Codableをそのまま入出力）
protocol CacheStore {
    func cache<T: Encodable>(key: String, encodable: T, ttl: TimeInterval) throws
    func get<T: Decodable>(key: String, as: T.Type) throws -> T?
    func remove(key: String)
    func removeAll()
}

// シンプルなメモリ実装（期限切れ対応）
final class DefaultCacheStore: CacheStore {                // <-- [ADDED]
    static let shared = DefaultCacheStore()                // <-- [ADDED]
    private init() {}

    private struct Entry {
        let data: Data
        let expiresAt: Date?
        var isExpired: Bool { expiresAt.map { $0 < Date() } ?? false }
    }
    private var storage: [String: Entry] = [:]
    private let lock = NSLock()

    func cache<T: Encodable>(key: String, encodable: T, ttl: TimeInterval) throws {
        let data = try JSONEncoder().encode(encodable)
        let exp = ttl > 0 ? Date().addingTimeInterval(ttl) : nil
        lock.lock(); defer { lock.unlock() }
        storage[key] = Entry(data: data, expiresAt: exp)
    }

    func get<T: Decodable>(key: String, as: T.Type) throws -> T? {
        lock.lock(); defer { lock.unlock() }
        guard let e = storage[key] else { return nil }
        if e.isExpired { storage.removeValue(forKey: key); return nil }
        return try JSONDecoder().decode(T.self, from: e.data)
    }

    func remove(key: String) {
        lock.lock(); defer { lock.unlock() }
        storage.removeValue(forKey: key)
    }

    func removeAll() {
        lock.lock(); defer { lock.unlock() }
        storage.removeAll()
    }
}
