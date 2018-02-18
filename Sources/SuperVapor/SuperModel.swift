//
//  SuperModel.swift
//

import Foundation
import FluentProvider

class SuperModel: CustomStringConvertible, JSONSettable, JSONConvertible {
    
    enum SuperModelError: Error {
        case problem
    }
    
    enum PropDef {
        case int(name: String)
        case string(name: String)
        case double(name: String)
        case date(name: String)
        case foreignKey(key: ForeignKey)
    }
    
    enum Prop {
        case int(name: String, getter: () -> Int, setter: (Int) -> ())
        case string(name: String, getter: () -> String, setter: (String) -> ())
        case double(name: String, getter: () -> Double, setter: (Double) -> ())
        case date(name: String, getter: () -> Date, setter: (Date) -> ())
        case foreignKey(name: String, getter:() -> Identifier?, setter:(Identifier?) -> ())
    }
    
    static let ID_KEY = "id"
    
    var props: [Prop] = []
    
    // MARK: Model (support)
    
    let storage = Storage()
    
    func set(row: Row) throws {
        for prop in props {
            switch prop {
            case .int(let name, _, let setter):
                try setter(row.get(name))
            case .string(let name, _, let setter):
                try setter(row.get(name))
            case .double(let name, _, let setter):
                try setter(row.get(name))
            case .date(let name, _, let setter):
                try setter(row.get(name))
            case .foreignKey(let name, _, let setter):
                try setter(row.get(name))
            }
        }
    }
    
    func makeRow() throws -> Row {
        var row = Row()
        
        for prop in props {
            switch prop {
            case .int(let name, let getter, _):
                try row.set(name, getter())
            case .string(let name, let getter, _):
                try row.set(name, getter())
            case .double(let name, let getter, _):
                try row.set(name, getter())
            case .date(let name, let getter, _):
                try row.set(name, getter())
            case .foreignKey(let name, let getter, _):
                try row.set(name, getter())
            }
        }
        
        return row
    }
    
    // MARK: CustomStringConvertible
    var description: String {
        var rv = ""
        for prop in props {
            switch prop {
            case .int(let name, let getter, _):
                rv += "\(name): \(getter()) "
            case .string(let name, let getter, _):
                rv += "\(name): \(getter()) "
            case .double(let name, let getter, _):
                rv += "\(name): \(getter()) "
            case .date(let name, let getter, _):
                rv += "\(name): \(getter()) "
            case .foreignKey(let name, let getter, _):
                rv += "\(name): \(String(describing: getter()))"
            }
        }
        
        return rv
    }
    
    // MARK: Preparation (support)
    static func prepareDb(builder: Builder, propDefs: [PropDef]) {
        builder.id()
        
        for prop in propDefs {
            switch prop {
            case .int(let name):
                builder.int(name)
            case .string(let name):
                builder.string(name)
            case .double(let name):
                builder.double(name)
            case .date(let name):
                builder.date(name)
            case .foreignKey(let key):
                builder.int(key.field, optional: true)
                builder.foreignKey(key)
            }
        }
    }
    
    // MARK: JSONSettable
    func set(json: JSON) {
        // any prop missing from the JSON is ignored
        for prop in props {
            switch prop {
            case .int(let name, _, let setter):
                do {
                    try setter(json.get(name))
                } catch {}
            case .string(let name, _, let setter):
                do {
                    try setter(json.get(name))
                } catch {}
            case .double(let name, _, let setter):
                do {
                    try setter(json.get(name))
                } catch {}
            case .date(let name, _, let setter):
                do {
                    try setter(json.get(name))
                } catch {}
            case .foreignKey(let name, _, let setter):
                do {
                    try setter(json.get(name))
                } catch {}
            }
        }
    }
    
    // MARK: JSONConvertible
    func makeJSON() throws -> JSON {
        var json = JSON()
        for prop in props {
            switch prop {
            case .int(let name, let getter, _):
                try json.set(name, getter())
            case .string(let name, let getter, _):
                try json.set(name, getter())
            case .double(let name, let getter, _):
                try json.set(name, getter())
            case .date(let name, let getter, _):
                try json.set(name, getter())
            case .foreignKey(let name, let getter, _):
                try json.set(name, getter())
            }
        }
        
        return json
    }
    
    // MARK: Updateable (support)
    static func getUpdateableKeys<T: SuperModel>(propDefs: [PropDef]) -> [UpdateableKey<T>] {
        var keys: [UpdateableKey<T>] = []
        
        for (index, prop) in propDefs.enumerated() {
            switch prop {
            case .int(let name):
                keys.append(UpdateableKey(name, Int.self) { curator, i in
                    let prop = curator.props[index]
                    switch prop {
                    case .int(_, _, let setter):
                        setter(i)
                    default:
                        throw SuperModelError.problem
                    }
                })
            case .string(let name):
                keys.append(UpdateableKey(name, String.self) { curator, s in
                    let prop = curator.props[index]
                    switch prop {
                    case .string(_, _, let setter):
                        setter(s)
                    default:
                        throw SuperModelError.problem
                    }
                })
            case .double(let name):
                keys.append(UpdateableKey(name, Double.self) { curator, d in
                    let prop = curator.props[index]
                    switch prop {
                    case .double(_, _, let setter):
                        setter(d)
                    default:
                        throw SuperModelError.problem
                    }
                })
            case .date(let name):
                keys.append(UpdateableKey(name, Date.self) { curator, d in
                    let prop = curator.props[index]
                    switch prop {
                    case .date(_, _, let setter):
                        setter(d)
                    default:
                        throw SuperModelError.problem
                    }
                })
            case .foreignKey(let key):
                keys.append(UpdateableKey(key.field, Identifier.self) { curator, s in
                    let prop = curator.props[index]
                    switch prop {
                    case .foreignKey(_, _, let setter):
                        setter(s)
                    default:
                        throw SuperModelError.problem
                    }
                })
            }
        }
        return keys
    }
    
    // MARK: JSONConvertible
    required convenience init(json: JSON) throws {
        self.init()
        set(json: json)
    }
}

