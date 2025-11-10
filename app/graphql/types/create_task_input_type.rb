# app/graphql/types/create_task_input_type.rb
module Types
  class CreateTaskInputType < Types::BaseInputObject
    description "Attributes required to create a task"
    argument :title, String, required: true, description: "Short title describing the task"
    argument :description, String, required: true, description: "Detailed explanation of the task"
    argument :status, String, required: false, description: "Current status of the task (e.g.To Do, In Progress, Done)"
  end
end
