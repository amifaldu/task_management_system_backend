#!/usr/bin/env ruby

require_relative 'config/environment'

puts "🧪 Testing GraphQL Pagination..."
puts "=" * 50

# Add sample tasks
puts "📝 Creating sample tasks..."
Task.create(title: 'Task 1', description: 'First test task', status: 'To Do')
Task.create(title: 'Task 2', description: 'Second test task', status: 'In Progress')
Task.create(title: 'Task 3', description: 'Third test task', status: 'Done')
Task.create(title: 'Task 4', description: 'Fourth test task', status: 'To Do')
Task.create(title: 'Task 5', description: 'Fifth test task', status: 'In Progress')

puts "✅ Created #{Task.all.size} tasks"
puts

# Test 1: Basic query
puts "🔍 Test 1: Basic query"
query1 = '{ tasks { edges { node { title } } pageInfo { hasNextPage hasPreviousPage } totalCount } }'
result1 = TaskManagementSchema.execute(query1)
puts "📊 Total tasks: #{result1.dig('data', 'tasks', 'totalCount')}"
puts "📄 Edges: #{result1.dig('data', 'tasks', 'edges')&.size}"
puts "🔀 HasNextPage: #{result1.dig('data', 'tasks', 'pageInfo', 'hasNextPage')}"
puts

# Test 2: Limited results
puts "🔍 Test 2: Limited results (first: 2)"
query2 = 'query { tasks(first: 2) { edges { node { title } cursor } pageInfo { hasNextPage endCursor } totalCount } }'
result2 = TaskManagementSchema.execute(query2)
puts "📊 Total count: #{result2.dig('data', 'tasks', 'totalCount')}"
puts "📄 Returned: #{result2.dig('data', 'tasks', 'edges')&.size} tasks"
puts "🔀 HasNextPage: #{result2.dig('data', 'tasks', 'pageInfo', 'hasNextPage')}"
puts "📍 EndCursor: #{result2.dig('data', 'tasks', 'pageInfo', 'endCursor')}"
puts

# Test 3: Cursor navigation
end_cursor = result2.dig('data', 'tasks', 'pageInfo', 'endCursor')
if end_cursor
  puts "🔍 Test 3: Next page (after: #{end_cursor})"
  query3 = "query { tasks(first: 2, after: \"#{end_cursor}\") { edges { node { title } cursor } pageInfo { hasNextPage hasPreviousPage } totalCount } }"
  result3 = TaskManagementSchema.execute(query3)
  puts "📄 Returned: #{result3.dig('data', 'tasks', 'edges')&.size} tasks"
  puts "🔀 HasNextPage: #{result3.dig('data', 'tasks', 'pageInfo', 'hasNextPage')}"
  puts "🔀 HasPreviousPage: #{result3.dig('data', 'tasks', 'pageInfo', 'hasPreviousPage')}"
  puts
end

# Test 4: Status filtering
puts "🔍 Test 4: Status filtering (TO_DO)"
query4 = 'query { tasks(status: TO_DO) { edges { node { title status } } pageInfo { hasNextPage } totalCount } }'
result4 = TaskManagementSchema.execute(query4)
puts "📊 Total TO_DO tasks: #{result4.dig('data', 'tasks', 'totalCount')}"
puts "📄 Returned: #{result4.dig('data', 'tasks', 'edges')&.size} tasks"
result4.dig('data', 'tasks', 'edges')&.each do |edge|
  puts "  - #{edge.dig('node', 'title')} (#{edge.dig('node', 'status')})"
end
puts

# Test 5: Filtered pagination
puts "🔍 Test 5: Filtered pagination (first: 1, status: TO_DO)"
query5 = 'query { tasks(first: 1, status: TO_DO) { edges { node { title status } } pageInfo { hasNextPage } totalCount } }'
result5 = TaskManagementSchema.execute(query5)
puts "📊 Total TO_DO: #{result5.dig('data', 'tasks', 'totalCount')}"
puts "📄 Returned: #{result5.dig('data', 'tasks', 'edges')&.size} task"
puts "🔀 HasNextPage: #{result5.dig('data', 'tasks', 'pageInfo', 'hasNextPage')}"
puts

puts "✅ All tests completed!"
puts "🌐 Visit http://localhost:3000/graphiql for interactive testing"
puts "=" * 50