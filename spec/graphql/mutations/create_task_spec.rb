require 'rails_helper'

RSpec.describe 'CreateTask Mutation', type: :request do
  let(:mutation) do
    <<~GRAPHQL
      mutation($input: CreateTaskInput!) {
        createTask(input: $input) {
          task {
            id
            title
            description
            status
            createdAt
            updatedAt
          }
          errors {
            field
            message
          }
        }
      }
    GRAPHQL
  end

  context 'when input is valid' do
    let(:variables) do
      {
        input: {
          title: 'Write specs',
          description: 'Add RSpec tests for GraphQL',
          status: 'TO_DO'
        }
      }
    end

    it 'creates a task successfully' do
      post '/graphql', params: { query: mutation, variables: variables }
      json = JSON.parse(response.body)
      data = json['data']['createTask']
      expect(data['task']['title']).to eq('Write specs')
      expect(data['task']['status']).to eq('TO_DO')
      expect(data['errors']).to be_empty
    end
  end

  context 'when title is missing' do
    let(:variables) do
      {
        input: {
          title: '',
          description: 'Missing title'
        }
      }
    end

    it 'returns a validation error for title' do
      post '/graphql', params: { query: mutation, variables: variables }
      json = JSON.parse(response.body)
      errors = json['data']['createTask']['errors']

      expect(errors).not_to be_empty
      expect(errors.first['field']).to eq('title')
    end
  end

  context 'when status is invalid' do
    let(:variables) do
      {
        input: {
          title: 'Invalid status',
          description: 'Bad status value',
          status: 'UNKNOWN'
        }
      }
    end

    it 'returns a validation error for status' do
      post '/graphql', params: { query: mutation, variables: variables }

      json = JSON.parse(response.body)

      # GraphQL enum validation errors appear at the top level, not in data.createTask.errors
      if json['data']&.dig('createTask')
        # If we get to the mutation, check for validation errors
        errors = json['data']['createTask']['errors']
        expect(errors.any? { |e| e['field'] == 'status' }).to be true
      else
        # GraphQL-level enum validation error
        expect(json['errors']).to be_present
        expect(json['errors'].first['message']).to include('status')
      end
    end
  end
end
