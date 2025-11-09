require 'securerandom'
require 'concurrent'

# In-memory model representing a task with validation and thread-safe storage
class Task
  include ActiveModel::Model
  include ActiveModel::Validations

  # Status constants to represent task lifecycle states
  STATUS_TO_DO = 'To Do'
  STATUS_IN_PROGRESS = 'In Progress'
  STATUS_DONE = 'Done'

  # Attributes representing task properties
  attr_accessor :id, :title, :description, :status, :created_at, :updated_at

  # Validation rules with I18n-friendly error keys
  VALID_STATUSES = [STATUS_TO_DO, STATUS_IN_PROGRESS, STATUS_DONE].freeze
  validates :status, inclusion: { in: VALID_STATUSES, message: :invalid_status }
  validates :title, presence: { message: :title_required }
  validates :description, presence: { message: :description_required }

  # Initialize a new Task instance with default status and timestamps
  def initialize(title:, description:, status: STATUS_TO_DO)
    @id = SecureRandom.uuid
    @title = title
    @description = description
    @status = status
    @created_at = Time.now
    @updated_at = Time.now
  end

  class << self
    # Thread-safe in-memory storage for all task instances
    def tasks
      @tasks ||= Concurrent::Array.new
    end

    # Return all tasks
    def all
      tasks
    end

    # Create and validate a new task; return task or invalid instance
    def create(title: nil, description: nil, status: STATUS_TO_DO)
      task = new(title: title, description: description, status: status)
      task.valid? ? (tasks << task && task) : task
    end

    # Find a task by its unique ID
    def find_by_id(id)
      tasks.find { |task| task.id == id }
    end

    # Update attributes of a task identified by its ID
    def update(id, title: nil, description: nil, status: nil)
      task = find_by_id(id)
      return { task: nil, errors: [{ field: "id", message: "Task not found" }] } unless task
      # Assign new values if provided
      task.title = title unless title.nil?
      task.description = description unless description.nil?
      task.status = status unless status.nil?
      task.updated_at = Time.now
      # Return updated task or formatted validation errors
      if task.valid?
        { task: task, errors: [] }
      else
        formatted_errors = task.errors.map do |error|
          {
            field: error.attribute.to_s,
            message: error.full_message
          }
        end
        { task: nil, errors: formatted_errors }
      end
    end

    # Delete a task by ID and return success status
    def delete(id)
      task = find_by_id(id)
      return { success: false, errors: [{ field: "id", message: "Task not found" }] } unless task

      tasks.delete(task)
      { success: true, errors: [] }
    end

    # Return tasks filtered by status, or all if no filter is applied
    def filter(status: nil)
      status ? tasks.select { |task| task.status == status } : tasks
    end
  end
end