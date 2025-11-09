require 'rails_helper'

RSpec.describe 'GraphQL Schema Types', type: :request do
  let(:introspection_query) do
    <<~GRAPHQL
      {
        __type(name: "CreateTaskInput") {
          name
          kind
          inputFields {
            name
            type {
              name
              kind
            }
          }
        }
      }
    GRAPHQL
  end

  it 'includes expected fields in CreateTaskInputType' do
    post '/graphql', params: { query: introspection_query }

    json = JSON.parse(response.body)
    fields = json['data']['__type']['inputFields'].map { |f| f['name'] }

    expect(fields).to include('title', 'description', 'status')
  end
end