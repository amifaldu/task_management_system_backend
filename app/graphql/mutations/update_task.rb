# GraphQL mutation for updating an existing task
module Mutations
  class UpdateTask < BaseMutation
    # Define the input argument type for the mutation
    argument :input, Types::UpdateTaskInputType, required: true

    # Define the fields returned in the mutation response
    field :task, Types::TaskType, null: true
    field :errors, [Types::FieldErrorType], null: false

    # Resolver method that performs the update operation
    def resolve(input:)
      # Extract the task ID and attributes to update
      id = input[:id]
      attrs = input.to_h.except(:id)

      # Attempt to find the task by ID
      task = Task.find_by_id(id)

      # Return error if task is not found
      return {
        task: nil,
        errors: [{ field: "id", message: "Task not found" }]
      } unless task

      # Assign new attributes to the task
      task.assign_attributes(attrs)

      # Validate the updated task
      if task.valid?
        # Update timestamp and return the updated task
        task.updated_at = Time.now
        { task: task, errors: [] }
      else
        # Format validation errors for GraphQL response
        formatted_errors = task.errors.map do |error|
          {
            field: error.attribute.to_s,
            message: error.full_message
          }
        end

        # Return nil task and formatted errors
        { task: nil, errors: formatted_errors }
      end
    end
  end
end