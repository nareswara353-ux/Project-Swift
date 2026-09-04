import Fluent
import Vapor

struct CreateTaskMigration: Migration {
    func prepare(on database: Database) async throws {
        try await database.schema("tasks")
            .id()
            .field("title", .string, .required)
            .field("description", .string)
            .field("status", .string, .required)
            .field("priority", .string, .required)
            .field("due_date", .datetime)
            .field("created_at", .datetime, .required)
            .field("updated_at", .datetime, .required)
            .field("user_id", .uuid, .required, .references("users", "id", onDelete: .cascade))
            .create()
    }

    func revert(on database: Database) async throws {
        try await database.schema("tasks").delete()
    }
}
