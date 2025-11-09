require 'rails_helper'

RSpec.describe 'GraphQL Integration', type: :request do
  let(:mutation) do
    <<~GRAPHQL
      mutation($input: CreateTaskInput!) {
        createTask(input: $input) {
          task {
            id
            title
            description
            status
          }
          errors {
            field
            message
          }
        }
      }
    GRAPHQL
  end

  it 'creates a task and returns correct JSON structure' do
    post '/graphql', params: {
      query: mutation,
      variables: {
        input: {
          title: 'Integration Test',
          description: 'Testing full flow',
          status: 'To Do'
        }
      }
    }

    json = JSON.parse(response.body)
    data = json['data']['createTask']

    expect(data['task']['title']).to eq('Integration Test')
    expect(data['errors']).to eq([])
  end
end