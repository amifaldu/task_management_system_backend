# app/graphql/types/status_enum.rb
module Types
  class StatusEnum < Types::BaseEnum
    value "TO_DO", value: "To Do", description: "The task has not been started yet"
    value "IN_PROGRESS", value: "In Progress", description: "The task is currently being worked on"
    value "DONE", value: "Done", description: "The task has been completed"
  end
end
