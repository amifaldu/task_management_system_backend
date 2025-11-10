# app/graphql/task_management_schema.rb
class TaskManagementSchema < GraphQL::Schema
  query(Types::QueryType)
  mutation(Types::MutationType)

  rescue_from(StandardError) do |err|
    raise GraphQL::ExecutionError, "Unexpected error: #{err.message}"
  end
end
