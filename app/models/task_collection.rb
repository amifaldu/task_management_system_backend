# Paginated collection wrapper for Task model to support GraphQL Connections
class TaskCollection
  include Enumerable

  attr_reader :collection, :total_count

  def initialize(collection)
    @collection = collection
    @total_count = collection.size
  end

  # Enumerable interface methods
  def each(&block)
    @collection.each(&block)
  end

  def size
    @collection.size
  end

  def length
    @collection.length
  end

  # Pagination methods required by GraphQL-Pagination
  def offset(limit)
    TaskCollection.new(@collection.drop(limit))
  end

  def limit(num)
    TaskCollection.new(@collection.first(num))
  end

  # Make sure to_a returns the collection, not self
  def to_ary
    @collection
  end

  # Support for cursor-based pagination
  def to_a
    @collection
  end

  # Get task by index for cursor generation
  def [](index)
    @collection[index]
  end

  # Support for slicing operations
  def slice(start, length)
    TaskCollection.new(@collection[start, length] || [])
  end

  # Empty check
  def empty?
    @collection.empty?
  end

  # First and last for cursor operations
  def first
    @collection.first
  end

  def last
    @collection.last
  end

  # Support for GraphQL connection
  def cursor_for(item)
    # Use the index as cursor - in production with real DB, use primary key
    index = @collection.find_index { |task| task.id == item.id }
    index&.to_s
  end
end