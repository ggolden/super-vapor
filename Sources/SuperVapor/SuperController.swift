//
//  SuperController.swift
//

import FluentProvider

class SuperController<Base: Model & JSONConvertible & ResponseRepresentable & Updateable & JSONSettable>: ResourceRepresentable {
    // register in Routes/Routes.swift
    
    // Override this to add per item authorization
    func authorized(_ req: Request, entity: Base) -> Bool {
        return true
    }
    
    // Override this to add a filter to the bulk (get, delete) operations
    func bulkFilter(_ req: Request) throws -> (field: String, comparison: Fluent.Filter.Comparison, value: NodeRepresentable?)? {
        return nil
    }
    
    // Override to, before a post, put or patch, authorize and validate / repair the entity
    func validate(_ req: Request, entity: Base) throws {
    }
    
    // GET /base
    func index(_ req: Request) throws -> ResponseRepresentable {
        if let filter = try bulkFilter(req) {
            return try Base.makeQuery().filter(filter.field, filter.comparison, filter.value).all().makeJSON()
        } else {
            return try Base.all().makeJSON()
        }
    }
    
    // POST /base
    func store(_ req: Request) throws -> ResponseRepresentable {
        let entity = try entityFrom(req: req)
        
        try validate(req, entity: entity)
        
        try entity.save()
        return entity
    }
    
    // GET /base/id
    func show(_ req: Request, entity: Base) throws -> ResponseRepresentable {
        if (authorized(req, entity: entity)) {
            return entity
        }
        
        throw Abort(.unauthorized)
    }
    
    // DELETE /base/id
    func delete(_ req: Request, entity: Base) throws -> ResponseRepresentable {
        if (authorized(req, entity: entity)) {
            try entity.delete()
            return Response(status: .ok)
        }
        
        throw Abort(.unauthorized)
    }
    
    // DELETE /base
    func clear(_ req: Request) throws -> ResponseRepresentable {
        if let filter = try bulkFilter(req) {
            try Base.makeQuery().filter(filter.field, filter.comparison, filter.value).delete()
        } else {
            try Base.makeQuery().delete()
        }
        
        return Response(status: .ok)
    }
    
    // PATCH /base/id
    func update(_ req: Request, entity: Base) throws -> ResponseRepresentable {
        if (authorized(req, entity: entity)) {
            try entity.update(for: req)
            
            try validate(req, entity: entity)
            
            try entity.save()
            return entity
        }
        
        throw Abort(.unauthorized)
    }
    
    // PUT /base/id
    func replace(_ req: Request, entity: Base) throws -> ResponseRepresentable {
        if (authorized(req, entity: entity)) {
            let newEntity = try entityFrom(req: req)
            let json = try newEntity.makeJSON()
            entity.set(json: json)
            
            try validate(req, entity: entity)
            
            try entity.save()
            return entity
        }
        
        throw Abort(.unauthorized)
    }
    
    // register the REST handlers
    func makeResource() -> Resource<Base> {
        return Resource(
            index: index,
            store: store,
            show: show,
            update: update,
            replace: replace,
            destroy: delete,
            clear: clear
        )
    }
    
    // pull an entity (via JSON) from the request
    func entityFrom(req: Request) throws -> Base {
        guard let json = req.json else { throw Abort.badRequest }
        return try Base(json: json)
    }
}

