require 'rails_helper'

RSpec.describe 'DeleteTask Mutation', type: :request do
  let(:task) { Task.create(title: 'To Be Deleted', description: 'Delete me') }

  let(:mutation) do
    <<~GRAPHQL
      mutation($id: ID!) {
        deleteTask(id: $id) {
          success
          errors {
            field
            message
          }
        }
      }
    GRAPHQL
  end

  context 'when task exists' do
    it 'deletes the task successfully' do
      post '/graphql', params: { query: mutation, variables: { id: task.id } }

      json = JSON.parse(response.body)
      data = json['data']['deleteTask']

      expect(data['success']).to be true
      expect(data['errors']).to be_empty
      expect(Task.find_by_id(task.id)).to be_nil
    end
  end

  context 'when task ID is invalid' do
    it 'returns an error for missing task' do
      post '/graphql', params: { query: mutation, variables: { id: 'invalid-id' } }

      json = JSON.parse(response.body)
      data = json['data']['deleteTask']

      expect(data['success']).to be false
      expect(data['errors'].first['field']).to eq('id')
    end
  end

  context 'when ID is blank' do
    it 'returns an error for blank ID' do
      post '/graphql', params: { query: mutation, variables: { id: '' } }

      json = JSON.parse(response.body)
      data = json['data']['deleteTask']

      expect(data['success']).to be false
      expect(data['errors'].first['field']).to eq('id')
    end
  end
end
