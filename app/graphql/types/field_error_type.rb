# GraphQL object type representing a validation or business logic error
module Types
  class FieldErrorType < Types::BaseObject
    field :field, String, null: false
    field :message, String, null: false
  end
end
