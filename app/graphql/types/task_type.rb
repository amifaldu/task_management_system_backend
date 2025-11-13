# app/graphql/types/task_type.rb
module Types
  class TaskType < Types::BaseObject
    field :id, ID, null: false, description: "Unique identifier for the task"
    field :title, String, null: false, description: "Short title describing the task"
    field :description, String, null: false, description: "Detailed explanation of what the task involves"
    field :status, Types::StatusEnum, null: false, description: "Current status of the task (e.g., To Do, In Progress, Done)"
    field :created_at, GraphQL::Types::ISO8601DateTime, null: false, description: "Timestamp when the task was created"
    field :updated_at, GraphQL::Types::ISO8601DateTime, null: false, description: "Timestamp when the task was last updated"
  end
end
