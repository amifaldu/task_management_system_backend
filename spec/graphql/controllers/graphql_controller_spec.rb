require 'rails_helper'

RSpec.describe GraphqlController, type: :controller do
  describe 'POST #execute' do
    let(:query) do
      <<~GRAPHQL
        {
          __schema {
            queryType {
              name
            }
          }
        }
      GRAPHQL
    end

    it 'executes a valid query and returns 200' do
      post :execute, params: { query: query }
      expect(response).to have_http_status(:ok)
      expect(JSON.parse(response.body)).to have_key('data')
    end

    it 'returns error for invalid query' do
      post :execute, params: { query: 'invalid' }
      expect(response).to have_http_status(:ok)
      expect(JSON.parse(response.body)).to have_key('errors')
    end

    it 'returns 500 for unexpected error' do
      allow(TaskManagementSchema).to receive(:execute).and_raise(StandardError.new('Boom'))
      post :execute, params: { query: query }
      expect(response).to have_http_status(:internal_server_error)
      expect(JSON.parse(response.body)['errors'].first['message']).to eq('Boom')
    end
  end
end
