# Task Management System Backend

A modern, API-only Rails application with GraphQL endpoints for managing tasks. This backend provides a complete task management system with in-memory storage, pagination, and comprehensive error handling.

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
   git clone <repository-url>
   cd task_management_system_backend
   ```

2. **Install Ruby dependencies**
   ```bash
   bundle install
   ```

3. **Setup the database (for development)**
   ```bash
   rails db:create db:migrate
   ```
   *Note: This application uses in-memory storage, but Rails still requires database setup.*

4. **Run the development server**
   ```bash
   rails server
   ```

The server will start on `http://localhost:3000`.

## 🎯 Usage

### GraphQL Endpoint

- **Production/Staging**: `POST /graphql`
- **Development with GraphiQL**: Visit `http://localhost:3000/graphiql`

### GraphQL Schema

#### Queries

**Get paginated tasks**
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

#### Enums

- **StatusEnum**: `TO_DO`, `IN_PROGRESS`, `DONE`

## 🧪 Testing

Run the test suite:

```bash
# Run all tests
bundle exec rspec

# Run specific test files
bundle exec rspec spec/models/task_spec.rb
bundle exec rspec spec/requests/graphql_spec.rb

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

## 🔧 Configuration

### Environment Variables

The application works out-of-the-box with minimal configuration. For production:

```bash
# Rails environment
RAILS_ENV=production

# Server configuration (optional)
PORT=3000
BINDING=0.0.0.0
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
# Build the image
docker build -t task-management-backend .

# Run the container
docker run -p 3000:3000 task-management-backend
```

### Traditional Deployment

```bash
# Precompile assets (if needed)
RAILS_ENV=production bundle exec rails assets:precompile

# Start the server
RAILS_ENV=production bundle exec puma -C config/puma.rb
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
- **Scalability**: Suitable for development, testing, and small-scale applications
- **Production**: Consider migrating to a database (PostgreSQL, MySQL) for production use

### Migration to Database

To migrate to a database storage:

1. Generate ActiveRecord model: `rails g model task title:string description:text status:string`
2. Replace in-memory storage methods with ActiveRecord queries
3. Update the `Task` model to inherit from `ApplicationRecord` instead of `ActiveModel::Model`

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch: `git checkout -b feature-name`
3. Make your changes
4. Run tests: `bundle exec rspec`
5. Run linter: `bundle exec rubocop`
6. Commit changes: `git commit -m "Add feature description"`
7. Push to branch: `git push origin feature-name`
8. Open a Pull Request

## 📝 License

This project is licensed under the MIT License.

## 🆘 Troubleshooting

### Common Issues

**Server won't start:**
- Ensure Ruby 3.3.10 is installed
- Run `bundle install` to install dependencies
- Check if port 3000 is available

**GraphQL queries return errors:**
- Verify query syntax using GraphiQL at `/graphiql`
- Check required fields are provided
- Review error messages in response

**Tests failing:**
- Ensure all dependencies are installed: `bundle install`
- Run `rails db:test:prepare` if using database tests
- Check test configuration in `spec/rails_helper.rb`

**CORS issues:**
- Verify frontend origin is configured in `config/application.rb`
- Check that the Rails server is running
- Ensure proper HTTP headers are being sent

For additional support, please open an issue in the repository.
