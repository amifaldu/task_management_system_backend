# Controller responsible for handling incoming GraphQL queries and mutations
class GraphqlController < ApplicationController
  # Entry point for executing GraphQL operations
  def execute
    # Normalize incoming variables (can be JSON string, hash, or nil)
    variables = prepare_variables(params[:variables])

    # Extract GraphQL query string and optional operation name
    query = params[:query]
    operation_name = params[:operationName]

    # Define context for the request (e.g., current user, auth info)
    context = {} # Extend with authentication or session data if needed

    # Execute the GraphQL query using the application schema
    result = TaskManagementSchema.execute(
      query,
      variables: variables,
      context: context,
      operation_name: operation_name
    )

    # Respond with the result as JSON
    render json: result

  # Catch and report unexpected errors with a 500 status
  rescue => e
    render json: { errors: [{ message: e.message }] }, status: 500
  end

  private

  # Safely parse and normalize the variables parameter
  def prepare_variables(variables_param)
    case variables_param
    when String
      # Parse JSON string if present
      variables_param.present? ? JSON.parse(variables_param) : {}
    when Hash, ActionController::Parameters
      # Already a hash — return as-is
      variables_param
    when nil
      # No variables provided — return empty hash
      {}
    else
      # Raise error for unexpected input types
      raise ArgumentError, "Unexpected parameter: #{variables_param}"
    end
  end
end