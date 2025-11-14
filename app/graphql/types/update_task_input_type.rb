# app/graphql/types/update_task_input_type.rb
module Types
  class UpdateTaskInputType < Types::BaseInputObject
    description "Attributes required to update a task"
    argument :id, ID, required: true, description: "Unique identifier of the task to update"
    argument :title, String, required: true, description: "Short title describing the task"
    argument :description, String, required: true, description: "Detailed explanation of the task"
    argument :status, Types::StatusEnum, required: false, description: "Current status of the task"
  end
end
