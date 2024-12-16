import Fluent
import Vapor

final class Task: Model, Content, @unchecked Sendable {
    static let schema = "tasks"
    
    @ID(custom: .id, generatedBy: .database)
    var id: Int64?
    
    @Parent(key: "list_id")
    var list: TaskList
    
    @Field(key: "title")
    var title: String
    
    @Field(key: "description")
    var description: String
    
    @Field(key: "completed")
    var completed: Bool
    
    init() { }
    
    init(
        id: Int64? = nil,
        listID: Int64,
        title: String,
        description: String,
        completed: Bool = false
    ) {
        self.id = id
        self.$list.id = listID
        self.title = title
        self.description = description
        self.completed = completed
    }
}
extension TaskList {
    func taskDTO() -> TaskListDTO.Public {
        .init(
            id: self.id!,
            name: self.name,
            userId: self.$user.id
        )
    }
}
