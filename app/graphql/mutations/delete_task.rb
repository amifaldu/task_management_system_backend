# GraphQL mutation for deleting a task by its unique ID
module Mutations
  class DeleteTask < BaseMutation
    # Define the expected input argument
    argument :id, ID, required: true

    # Define the fields returned by the mutation
    field :success, Boolean, null: false
    field :errors, [Types::FieldErrorType], null: false

    # Resolver method that handles the deletion logic
    def resolve(id:)
      # Validate presence of ID (handles nil or empty string)
      if id.blank?
        return {
          success: false,
          errors: [
            {
              field: "id",
              message: I18n.t("errors.messages.id_required")
            }
          ]
        }
      end

      # Attempt to locate the task by ID
      task = ::Task.find_by_id(id)

      # Return error if task is not found
      unless task
        return {
          success: false,
          errors: [
            {
              field: "id",
              message: I18n.t("errors.messages.task_not_found")
            }
          ]
        }
      end
      
      # Remove the task from the in-memory store
      ::Task.tasks.delete(task)

      # Return success response
      {
        success: true,
        errors: []
      }
    end
  end
end
