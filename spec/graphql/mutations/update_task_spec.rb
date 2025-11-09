require 'rails_helper'

RSpec.describe 'UpdateTask Mutation', type: :request do
  let(:task) { Task.create(title: 'Initial Title', description: 'Initial Description') }

  let(:mutation) do
    <<~GRAPHQL
      mutation($input: UpdateTaskInput!) {
        updateTask(input: $input) {
          task {
            id
            title
            description
            status
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
          id: task.id,
          title: 'Updated Title',
          description: 'Updated Description',
          status: 'In Progress'
        }
      }
    end

    it 'updates the task successfully' do
      post '/graphql', params: { query: mutation, variables: variables }

      json = JSON.parse(response.body)
      data = json['data']['updateTask']

      expect(data['task']['title']).to eq('Updated Title')
      expect(data['task']['status']).to eq('In Progress')
      expect(data['errors']).to be_empty
    end
  end

  context 'when task ID is invalid' do
    it 'returns an error for missing task' do
      post '/graphql', params: {
        query: mutation,
        variables: { input: { id: 'non-existent-id', title: 'X', description: 'Y' } }
      }

      json = JSON.parse(response.body)
      data = json['data']['updateTask']

      expect(data['task']).to be_nil
      expect(data['errors'].first['field']).to eq('id')
    end
  end

  context 'when input is invalid' do
    it 'returns validation errors' do
      post '/graphql', params: {
        query: mutation,
        variables: { input: { id: task.id, title: '', description: '' } }
      }

      json = JSON.parse(response.body)
      data = json['data']['updateTask']

      expect(data['task']).to be_nil
      expect(data['errors'].map { |e| e['field'] }).to include('title', 'description')
    end
  end
end