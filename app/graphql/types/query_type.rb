  # app/graphql/types/query_type.rb
  module Types
    class QueryType < Types::BaseObject
      # Paginated tasks field following GraphQL Connections spec
      field :tasks, Types::TaskResult, null: false do
        argument :first, Integer, required: false, description: "Returns the first n items"
        argument :after, String, required: false, description: "Cursor for pagination"
        argument :status, Types::StatusEnum, required: false, description: "Filter tasks by status"
      end

      field :task, TaskType, null: true do
        argument :id, ID, required: true, description: "Get a specific task by ID"
      end

      def tasks(first: nil, after: nil, status: nil)
        all_tasks = status ? Task.filter(status: status) : Task.all
        # Get the raw collection for size calculation
        collection = all_tasks.to_a
        total_count = collection.size

        # Handle pagination - convert cursor (0-based index) to offset
        offset = after ? after.to_i + 1 : 0  # Add 1 to get next item after cursor
        limit = first || 10  # Default page size
        sliced_tasks = collection.slice(offset, limit) || []

        # Calculate pagination info
        has_next_page = (offset + limit) < total_count
        has_previous_page = offset > 0

        result = {
          edges: sliced_tasks.map.with_index do |task, index|
            {
              node: task,
              cursor: (offset + index).to_s
            }
          end,
          page_info: {
            has_next_page: has_next_page,
            has_previous_page: has_previous_page,
            start_cursor: sliced_tasks.any? ? offset.to_s : nil,
            end_cursor: sliced_tasks.any? ? (offset + sliced_tasks.size - 1).to_s : nil
          },
          total_count: total_count
        }

        result
      end

      def task(id:)
        Task.find_by_id(id)
      end
    end
  end
