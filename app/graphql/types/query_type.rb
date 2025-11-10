  # app/graphql/types/query_type.rb
  module Types
    class QueryType < Types::BaseObject
      field :tasks, [ TaskType ], null: false do
      argument :status, Types::StatusEnum, required: false
      end

      field :task, TaskType, null: true do
        argument :id, ID, required: true
      end

      def tasks(status: nil)
        status ? Task.filter(status: status) : Task.all
      end

      def task(id:)
        Task.find_by_id(id)
      end
    end
  end
