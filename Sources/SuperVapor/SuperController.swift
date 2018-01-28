//
//  SuperController.swift
//
//  glenn_golden@apple.com
//

import FluentProvider

open class SuperController<Base: Model & JSONConvertible & ResponseRepresentable & Updateable & JSONSettable>: ResourceRepresentable {
    // register in Routes/Routes.swift

    // GET /base
    func index(_ req: Request) throws -> ResponseRepresentable {
        return try Base.all().makeJSON()
    }
    
    // POST /base
    func store(_ req: Request) throws -> ResponseRepresentable {
        let entity = try entityFrom(req: req)
        try entity.save()
        return entity
    }
    
    // GET /base/id
    func show(_ req: Request, entity: Base) throws -> ResponseRepresentable {
        return entity
    }
    
    // DELETE /base/id
    func delete(_ req: Request, entity: Base) throws -> ResponseRepresentable {
        try entity.delete()
        return Response(status: .ok)
    }
    
    // DELETE /base
    func clear(_ req: Request) throws -> ResponseRepresentable {
        try Base.makeQuery().delete()
        return Response(status: .ok)
    }
    
    // PATCH /base/id
    func update(_ req: Request, entity: Base) throws -> ResponseRepresentable {
        try entity.update(for: req)
        try entity.save()
        return entity
    }
    
    // PUT /base/id
    func replace(_ req: Request, entity: Base) throws -> ResponseRepresentable {
        let newEntity = try entityFrom(req: req)
        let json = try newEntity.makeJSON()
        entity.set(json: json)
        try entity.save()
        return entity
    }
    
    // register the REST handlers
    public func makeResource() -> Resource<Base> {
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
