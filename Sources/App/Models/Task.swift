import Fluent
import Vapor

final class Task: Model, Content, @unchecked Sendable {
    static let schema = "tasks"
    
    @ID(custom: .id, generatedBy: .database)
    var id: Int64?
    
    @OptionalParent(key: "list_id")
    var list: TaskList?
    
    @Field(key: "title")
    var title: String
    
    @Field(key: "description")
    var description: String
    
    @Field(key: "completed")
    var completed: Bool
    
    init() { }
    
    init(
        id: Int64? = nil,
        listID: Int64? = nil,
        title: String,
        description: String,
        completed: Bool = false
    ) {
        self.id = id
        if let listID = listID {
            self.$list.id = listID
        }
        self.title = title
        self.description = description
        self.completed = completed
    }
    
    func toDTO() -> TaskDTO.Public {
            .init(
                id: self.id!,
                title: self.title,
                description: self.description,
                completed: self.completed,
                listId: self.$list.id
            )
        }
}
