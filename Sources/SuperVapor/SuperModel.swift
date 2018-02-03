import FluentProvider

open class SuperModel: CustomStringConvertible, JSONSettable, JSONConvertible {
    
    public enum SuperModelError: Error {
        case problem
    }
    
    public enum PropDef {
        case int(name: String)
        case string(name: String)
        case foreignKey(key: ForeignKey)
    }
    
    public enum Prop {
        case int(name: String, getter: () -> Int, setter: (Int) -> ())
        case string(name: String, getter: () -> String, setter: (String) -> ())
        case foreignKey(name: String, getter:() -> Identifier?, setter:(Identifier?) -> ())
    }
    
    public static let ID_KEY = "id"
    
    public var props: [Prop] = []
    
    // MARK: Model (support)
    
    public let storage = Storage()
    
    public func set(row: Row) throws {
        for prop in props {
            switch prop {
            case .int(let name, _, let setter):
                try setter(row.get(name))
            case .string(let name, _, let setter):
                try setter(row.get(name))
            case .foreignKey(let name, _, let setter):
                try setter(row.get(name))
            }
        }
    }
    
    public func makeRow() throws -> Row {
        var row = Row()
        
        for prop in props {
            switch prop {
            case .int(let name, let getter, _):
                try row.set(name, getter())
            case .string(let name, let getter, _):
                try row.set(name, getter())
            case .foreignKey(let name, let getter, _):
                try row.set(name, getter())
            }
        }
        
        return row
    }
    
    // MARK: CustomStringConvertible
    public var description: String {
        var rv = ""
        for prop in props {
            switch prop {
            case .int(let name, let getter, _):
                rv += "\(name): \(getter()) "
            case .string(let name, let getter, _):
                rv += "\(name): \(getter()) "
            case .foreignKey(let name, let getter, _):
                rv += "\(name): \(String(describing: getter()))"
            }
        }
        
        return rv
    }
    
    // MARK: Preparation (support)
    public static func prepareDb(builder: Builder, propDefs: [PropDef]) {
        builder.id()
        
        for prop in propDefs {
            switch prop {
            case .int(let name):
                builder.int(name)
            case .string(let name):
                builder.string(name)
            case .foreignKey(let key):
                builder.int(key.field, optional: true)
                builder.foreignKey(key)
            }
        }
    }
    
    // MARK: JSONSettable
    public func set(json: JSON) {
        do {
            for prop in props {
                switch prop {
                case .int(let name, _, let setter):
                    try setter(json.get(name))
                case .string(let name, _, let setter):
                    try setter(json.get(name))
                case .foreignKey(let name, _, let setter):
                    try setter(json.get(name))
                }
            }
        } catch {}
    }
    
    // MARK: JSONConvertible
    public func makeJSON() throws -> JSON {
        var json = JSON()
        for prop in props {
            switch prop {
            case .int(let name, let getter, _):
                try json.set(name, getter())
            case .string(let name, let getter, _):
                try json.set(name, getter())
            case .foreignKey(let name, let getter, _):
                try json.set(name, getter())
            }
        }
        
        return json
    }
    
    // MARK: Updateable (support)
    public static func getUpdateableKeys<T: SuperModel>(propDefs: [PropDef]) -> [UpdateableKey<T>] {
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
    required convenience public init(json: JSON) throws {
        self.init()
        set(json: json)
    }
}
