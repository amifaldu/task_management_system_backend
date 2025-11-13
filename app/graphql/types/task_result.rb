# Task result type for paginated responses
module Types
  class PageInfo < Types::BaseObject
    field :has_next_page, Boolean, null: false, description: "Whether there's a next page"
    field :has_previous_page, Boolean, null: false, description: "Whether there's a previous page"
    field :start_cursor, String, null: true, description: "Cursor for the first item"
    field :end_cursor, String, null: true, description: "Cursor for the last item"
  end

  class TaskEdge < Types::BaseObject
    field :node, Types::TaskType, null: false, description: "The task node"
    field :cursor, String, null: false, description: "Cursor for pagination"
  end

  class TaskResult < Types::BaseObject
    field :edges, [Types::TaskEdge], null: false, description: "Edges containing task nodes and cursors"
    field :page_info, Types::PageInfo, null: false, description: "Pagination information"
    field :total_count, Integer, null: false, description: "Total number of tasks"
  end
end