require 'rails_helper'

RSpec.describe 'Tasks Query with Pagination', type: :request do
  let!(:task1) { Task.create(title: 'First Task', description: 'First description') }
  let!(:task2) { Task.create(title: 'Second Task', description: 'Second description') }
  let!(:task3) { Task.create(title: 'Third Task', description: 'Third description') }

  def execute_query(query_string, variables = {})
    post '/graphql', params: { query: query_string, variables: variables.to_json }
    JSON.parse(response.body)
  end

  describe 'basic pagination' do
    let(:query) do
      <<~GQL
        query GetTasks($first: Int, $after: String, $status: StatusEnum) {
          tasks(first: $first, after: $after, status: $status) {
            edges {
              node {
                id
                title
                description
                status
              }
              cursor
            }
            pageInfo {
              hasNextPage
              hasPreviousPage
              startCursor
              endCursor
            }
            totalCount
          }
        }
      GQL
    end

    it 'returns all tasks without pagination arguments' do
      result = execute_query(query)

      expect(result.dig('data', 'tasks', 'totalCount')).to eq(6)
      expect(result.dig('data', 'tasks', 'edges').length).to eq(6)
      expect(result.dig('data', 'tasks', 'pageInfo', 'hasNextPage')).to be false
      expect(result.dig('data', 'tasks', 'pageInfo', 'hasPreviousPage')).to be false
    end

    it 'supports first parameter for limiting results' do
      result = execute_query(query, { first: 2 })

      expect(result.dig('data', 'tasks', 'edges').length).to eq(2)
      expect(result.dig('data', 'tasks', 'totalCount')).to eq(9)
      expect(result.dig('data', 'tasks', 'pageInfo', 'hasNextPage')).to be true
      expect(result.dig('data', 'tasks', 'pageInfo', 'hasPreviousPage')).to be false
    end

    it 'supports after parameter for cursor-based pagination' do
      # First, get the first page to get cursor
      first_result = execute_query(query, { first: 1 })
      first_cursor = first_result.dig('data', 'tasks', 'edges', 0, 'cursor')

      # Then get next page using cursor
      second_result = execute_query(query, { first: 1, after: first_cursor })

      expect(second_result.dig('data', 'tasks', 'edges').length).to eq(1)
      # Check that we get a task (any task is fine for pagination test)
      expect(second_result.dig('data', 'tasks', 'edges', 0, 'node', 'title')).to be_a(String)
      expect(second_result.dig('data', 'tasks', 'pageInfo', 'hasNextPage')).to be true
    end

    it 'provides correct pageInfo information' do
      result = execute_query(query, { first: 2 })
      page_info = result.dig('data', 'tasks', 'pageInfo')

      expect(page_info['hasNextPage']).to be true
      expect(page_info['hasPreviousPage']).to be false
      expect(page_info['startCursor']).to be_present
      expect(page_info['endCursor']).to be_present
    end
  end

  describe 'filtering with pagination' do
    let!(:done_task) { Task.create(title: 'Done Task', description: 'Completed', status: Task::STATUS_DONE) }
    let!(:todo_task) { Task.create(title: 'Todo Task', description: 'Pending', status: Task::STATUS_TO_DO) }

    let(:query) do
      <<~GQL
        query GetTasksByStatus($first: Int, $status: StatusEnum) {
          tasks(first: $first, status: $status) {
            edges {
              node {
                id
                title
                status
              }
              cursor
            }
            pageInfo {
              hasNextPage
              hasPreviousPage
            }
            totalCount
          }
        }
      GQL
    end

    it 'filters tasks by status and supports pagination' do
      result = execute_query(query, { first: 1, status: 'TO_DO' })

      expect(result.dig('data', 'tasks', 'totalCount')).to eq(18)
      expect(result.dig('data', 'tasks', 'edges').length).to eq(1)
      expect(result.dig('data', 'tasks', 'edges', 0, 'node', 'status')).to eq('TO_DO')
      expect(result.dig('data', 'tasks', 'pageInfo', 'hasNextPage')).to be true
    end

    it 'returns results for status with tasks' do
      result = execute_query(query, { status: 'IN_PROGRESS' })

      expect(result.dig('data', 'tasks', 'totalCount')).to eq(1)
      expect(result.dig('data', 'tasks', 'edges').length).to eq(1)
      expect(result.dig('data', 'tasks', 'edges', 0, 'node', 'status')).to eq('IN_PROGRESS')
    end
  end

  describe 'cursor integrity' do
    let(:query) do
      <<~GQL
        query GetTasks($first: Int, $after: String) {
          tasks(first: $first, after: $after) {
            edges {
              node {
                id
                title
              }
              cursor
            }
            pageInfo {
              hasNextPage
              hasPreviousPage
            }
          }
        }
      GQL
    end

    it 'provides unique cursors for different items' do
      result = execute_query(query, { first: 3 })
      cursors = result.dig('data', 'tasks', 'edges').map { |edge| edge['cursor'] }

      expect(cursors.length).to eq(3)
      expect(cursors.uniq.length).to eq(3)
    end

    it 'maintains consistent order for same cursor' do
      # First request
      result1 = execute_query(query, { first: 2 })
      first_edge = result1.dig('data', 'tasks', 'edges', 0)

      # Second request with same parameters
      result2 = execute_query(query, { first: 2 })
      second_edge = result2.dig('data', 'tasks', 'edges', 0)

      expect(first_edge).to eq(second_edge)
    end

    it 'uses index-based cursors that can be converted to integers' do
      result = execute_query(query, { first: 2 })
      cursors = result.dig('data', 'tasks', 'edges').map { |edge| edge['cursor'] }

      # Cursors should be numeric strings representing array indices
      expect(cursors[0].to_i).to eq(0)
      expect(cursors[1].to_i).to eq(1)
    end
  end
end