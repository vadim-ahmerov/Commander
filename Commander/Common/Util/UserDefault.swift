import Foundation
import SwiftUI

// MARK: - UserDefault

@propertyWrapper
public struct UserDefault<Value> {
    private let get: () -> Value
    private let set: (Value) -> Void

    public var wrappedValue: Value {
        get { get() }
        nonmutating set { set(newValue) }
    }
}

extension UserDefault {
    public init(wrappedValue: Value, _ key: String, store: UserDefaults = .standard) where Value == Bool {
        self.init(defaultValue: wrappedValue, key: key, store: store)
    }

    public init(wrappedValue: Value, _ key: String, store: UserDefaults = .standard) where Value == Int {
        self.init(defaultValue: wrappedValue, key: key, store: store)
    }

    public init(wrappedValue: Value, _ key: String, store: UserDefaults = .standard) where Value == Double {
        self.init(defaultValue: wrappedValue, key: key, store: store)
    }

    public init(wrappedValue: Value, _ key: String, store: UserDefaults = .standard) where Value == String {
        self.init(defaultValue: wrappedValue, key: key, store: store)
    }

    public init(wrappedValue: Value, _ key: String, store: UserDefaults = .standard) where Value == URL {
        self.init(defaultValue: wrappedValue, key: key, store: store)
    }

    public init(wrappedValue: Value, _ key: String, store: UserDefaults = .standard) where Value == Data {
        self.init(defaultValue: wrappedValue, key: key, store: store)
    }

    private init(defaultValue: Value, key: String, store: UserDefaults) {
        get = {
            let value = store.value(forKey: key) as? Value
            return value ?? defaultValue
        }

        set = { newValue in
            store.set(newValue, forKey: key)
        }
    }
}

extension UserDefault where Value: Codable {
    public init(wrappedValue defaultValue: Value, _ key: String, store: UserDefaults = .standard) {
        get = {
            let data = store.value(forKey: key) as? Data
            return data.flatMap {
                try? JSONDecoder().decode(Value.self, from: $0)
            } ?? defaultValue
        }

        set = { newValue in
            let data = try? JSONEncoder().encode(newValue)
            store.set(data, forKey: key)
        }
    }
}

extension UserDefault where Value: ExpressibleByNilLiteral {
    public init(_ key: String, store: UserDefaults = .standard) where Value == Bool? {
        self.init(wrappedType: Bool.self, key: key, store: store)
    }

    public init(_ key: String, store: UserDefaults = .standard) where Value == Int? {
        self.init(wrappedType: Int.self, key: key, store: store)
    }

    public init(_ key: String, store: UserDefaults = .standard) where Value == Double? {
        self.init(wrappedType: Double.self, key: key, store: store)
    }

    public init(_ key: String, store: UserDefaults = .standard) where Value == String? {
        self.init(wrappedType: String.self, key: key, store: store)
    }

    public init(_ key: String, store: UserDefaults = .standard) where Value == URL? {
        self.init(wrappedType: URL.self, key: key, store: store)
    }

    public init(_ key: String, store: UserDefaults = .standard) where Value == Data? {
        self.init(wrappedType: Data.self, key: key, store: store)
    }

    private init<T>(wrappedType _: T.Type, key: String, store: UserDefaults) {
        get = {
            let value = store.value(forKey: key) as? Value
            return value ?? nil
        }

        set = { newValue in
            let newValue = newValue as? T?

            if let newValue = newValue {
                store.set(newValue, forKey: key)
            } else {
                store.removeObject(forKey: key)
            }
        }
    }
}

extension UserDefault where Value: RawRepresentable {
    public init(wrappedValue: Value, _ key: String, store: UserDefaults = .standard) where Value.RawValue == String {
        self.init(defaultValue: wrappedValue, key: key, store: store)
    }

    public init(wrappedValue: Value, _ key: String, store: UserDefaults = .standard) where Value.RawValue == Int {
        self.init(defaultValue: wrappedValue, key: key, store: store)
    }

    public init(wrappedValue: Value, _ key: String, store: UserDefaults = .standard) where Value.RawValue == UInt {
        self.init(defaultValue: wrappedValue, key: key, store: store)
    }

    private init(defaultValue: Value, key: String, store: UserDefaults) {
        get = {
            var value: Value?

            if let rawValue = store.value(forKey: key) as? Value.RawValue {
                value = Value(rawValue: rawValue)
            }

            return value ?? defaultValue
        }

        set = { newValue in
            let value = newValue.rawValue
            store.set(value, forKey: key)
        }
    }
}

extension UserDefault {
    public init<R>(_ key: String, store: UserDefaults = .standard) where Value == R?, R: RawRepresentable, R.RawValue == Int {
        self.init(key: key, store: store)
    }

    public init<R>(_ key: String, store: UserDefaults = .standard) where Value == R?, R: RawRepresentable, R.RawValue == String {
        self.init(key: key, store: store)
    }

    private init<R>(key: String, store: UserDefaults) where Value == R?, R: RawRepresentable {
        get = {
            if let rawValue = store.value(forKey: key) as? R.RawValue {
                return R(rawValue: rawValue)
            } else {
                return nil
            }
        }

        set = { newValue in
            let newValue = newValue as R?

            if let newValue = newValue {
                store.set(newValue.rawValue, forKey: key)
            } else {
                store.removeObject(forKey: key)
            }
        }
    }
}
