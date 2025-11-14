# Task Management System Backend

API-only Rails application with GraphQL endpoints for task management. This backend provides a complete task management system with in-memory storage, pagination, and error handling.

## 🚀 Features

- **GraphQL API**: Complete GraphQL schema with queries and mutations
- **Task CRUD Operations**: Create, read, update, and delete tasks
- **Status Management**: Tasks have three statuses: "To Do", "In Progress", "Done"
- **Pagination**: Cursor-based pagination following GraphQL Connections specification
- **Filtering**: Filter tasks by status
- **In-Memory Storage**: Thread-safe, concurrent data storage using `concurrent-ruby`
- **Error Handling**: Structured error responses with field-level validation
- **Testing**: Comprehensive RSpec test suite
- **GraphiQL**: Interactive GraphQL testing interface (development only)

## 📋 Requirements

- Ruby 3.3.10
- Rails 8.1.1
- Bundler

## 🛠️ Installation

1. **Clone the repository**
   ```bash
   git clone https://github.com/amifaldu/task_management_system_backend.git
   cd task_management_system_backend
   ```

2. **Install Ruby dependencies**
   Initialize a new gemset (if using RVM) then install bundler
   ```bash
   gem install bundler
   ```
   Install the application dependencies
   
   ```bash
   bundle install
   ```
   
   *Note: This application uses in-memory storage, so no migration is required.
5. **Run the development server**
   ```bash
   rails server
   ```

The server will start on `http://localhost:3000`.

## 🎯 Usage

### GraphQL Endpoint

- **Development with GraphiQL**: Visit `http://localhost:3000/graphiql`

### GraphQL Schema

#### Queries

**Get Task List with pagination**
```graphql
query GetTasks($first: Int, $after: String, $status: StatusEnum) {
  tasks(first: $first, after: $after, status: $status) {
    edges {
      node {
        id
        title
        description
        status
        createdAt
        updatedAt
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
```

**Get a specific task**
```graphql
query GetTask($id: ID!) {
  task(id: $id) {
    id
    title
    description
    status
    createdAt
    updatedAt
  }
}
```

#### Mutations

**Create a task**
```graphql
mutation CreateTask($title: String!, $description: String!, $status: StatusEnum) {
  createTask(input: { title: $title, description: $description, status: $status }) {
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
```

**Update a task**
```graphql
mutation UpdateTask($id: ID!, $title: String, $description: String, $status: StatusEnum) {
  updateTask(input: { id: $id, title: $title, description: $description, status: $status }) {
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
```

**Delete a task**
```graphql
mutation DeleteTask($id: ID!) {
  deleteTask(input: { id: $id }) {
    success
    errors {
      field
      message
    }
  }
}
```

## 🧪 Testing

Run the test suite:

```bash
# Run all tests
bundle exec rspec

# Run model specific test files
bundle exec rspec spec/models/task_spec.rb
bundle exec rspec spec/models/task_collection_spec.rb

# Run controller specific test files
bundle exec rspec spec/graphql/controller/graphql_controller_spec.rb

# Run Graphql mutation specific test files
bundle exec rspec spec/graphql/mutations/create_task_spec.rb
bundle exec rspec spec/graphql/mutations/update_task_spec.rb
bundle exec rspec spec/graphql/mutations/delete_task_spec.rb

# Run Graphql query specific test files
bundle exec rspec spec/graphql/queries/tasks_query_spec.rb

# Run with coverage
bundle exec rspec --format documentation
```

## 📁 Project Structure

```
app/
├── graphql/
│   ├── graphql_controller.rb    # GraphQL endpoint controller
│   ├── types/
│   │   ├── query_type.rb        # GraphQL queries
│   │   ├── mutation_type.rb     # GraphQL mutations
│   │   ├── task_type.rb         # Task GraphQL type
│   │   └── base_object.rb       # Base GraphQL type
│   └── mutations/
│       ├── create_task.rb       # Create task mutation
│       ├── update_task.rb       # Update task mutation
│       └── delete_task.rb       # Delete task mutation
├── models/
│   ├── task.rb                  # Main task model with in-memory storage
│   └── task_collection.rb       # Paginated collection wrapper
└── controllers/
    └── application_controller.rb
```

### CORS Configuration

The application is pre-configured to work with a React frontend on `http://localhost:5173`. To modify:

Edit `config/application.rb` and update the CORS origins:

```ruby
config.middleware.insert_before 0, Rack::Cors do
  allow do
    origins 'http://localhost:5173', 'https://your-frontend-domain.com'
    resource '*',
      headers: :any,
      methods: [:get, :post, :put, :patch, :delete, :options, :head]
  end
end
```

## 🚀 Deployment

### Docker Deployment

A `Dockerfile` is included for containerized deployment:

```bash
# Docker build
docker compose -f docker-compose.yml up --build

#Stopping the Application
docker compose down

#Viewing Logs
docker compose logs
```

## 📊 API Examples

### Using curl

**Create a task:**
```bash
curl -X POST http://localhost:3000/graphql \
  -H "Content-Type: application/json" \
  -d '{
    "query": "mutation { createTask(input: { title: \"Learn GraphQL\", description: \"Study GraphQL basics\", status: TO_DO }) { task { id title } } }"
  }'
```

**Get tasks:**
```bash
curl -X POST http://localhost:3000/graphql \
  -H "Content-Type: application/json" \
  -d '{
    "query": "query { tasks(first: 5) { edges { node { title status } } pageInfo { hasNextPage } } }"
  }'
```

## 🛠️ Development

### Code Style

This project uses RuboCop with the `rubocop-rails-omakase` configuration:

```bash
# Run linter
bundle exec rubocop

# Auto-fix issues
bundle exec rubocop -a
```

### Debugging

Use `binding.pry` or `binding.irb` in the code for debugging. The `pry` gem is included for development.

### Adding New Features

1. **Models**: Add business logic to `app/models/`
2. **GraphQL Types**: Define new types in `app/graphql/types/`
3. **Mutations/Queries**: Add to respective mutation/query type files
4. **Tests**: Add corresponding tests in `spec/`

## 🔍 Data Storage

This application uses **in-memory storage** for simplicity and performance:

- **Storage**: `Concurrent::Array` for thread-safe operations
- **Persistence**: Data is lost on server restart

For additional support, please open an issue in the repository.

## Author

* **Ami Faldu** 
