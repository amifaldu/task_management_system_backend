# GraphQL mutation for updating an existing task
module Mutations
  class UpdateTask < BaseMutation
    # Define the input argument type for the mutation
    argument :input, Types::UpdateTaskInputType, required: true

    # Define the fields returned in the mutation response
    field :task, Types::TaskType, null: true
    field :errors, [ Types::FieldErrorType ], null: false

    # Resolver method that performs the update operation
    def resolve(input:)
      # Extract the task ID and attributes to update
      id = input[:id]
      title = input[:title]
      description = input[:description]
      status = input[:status]

      # Use the Task model's update method
      result = Task.update(id, title: title, description: description, status: status)

      result
    end
  end
end
