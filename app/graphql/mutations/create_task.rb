# GraphQL mutation for creating a new task
module Mutations
  class CreateTask < BaseMutation
    # Define the expected input argument type
    argument :input, Types::CreateTaskInputType, required: true

    # Define the fields returned by the mutation
    field :task, Types::TaskType, null: true
    field :errors, [ Types::FieldErrorType ], null: false

    # Main resolver method that handles task creation
    def resolve(input:)
      # Create a new task using the provided input attributes
      task = Task.create(**input.to_h)

      # If the task is valid, return it with no errors
      if task.valid?
        { task: task, errors: [] }
      else
        # Format validation errors for GraphQL response
        formatted_errors = task.errors.map do |error|
          {
            field: error.attribute.to_s,
            message: error.full_message
          }
        end
        # Return nil task and the formatted errors
        { task: nil, errors: formatted_errors }
      end
    end
  end
end
