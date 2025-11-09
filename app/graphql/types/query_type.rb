# app/graphql/types/query_type.rb
module Types
  class QueryType < Types::BaseObject
    field :tasks, [TaskType], null: false do
    argument :status, Types::StatusEnum, required: false
    end

    def tasks(status: nil)
      status ? Task.filter(status: status) : Task.all
    end
  end
end