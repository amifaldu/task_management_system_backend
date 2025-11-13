require 'rails_helper'

RSpec.describe TaskCollection, type: :model do
  let(:task1) { Task.create(title: 'Task 1', description: 'Description 1') }
  let(:task2) { Task.create(title: 'Task 2', description: 'Description 2') }
  let(:task3) { Task.create(title: 'Task 3', description: 'Description 3') }
  let(:tasks) { [task1, task2, task3] }

  subject { described_class.new(tasks) }

  describe '#initialize' do
    it 'wraps the provided collection' do
      collection = described_class.new(tasks)
      expect(collection.to_a).to eq(tasks)
      expect(collection.total_count).to eq(3)
    end
  end

  describe 'enumerable interface' do
    it 'supports iteration' do
      result = []
      subject.each { |task| result << task.title }
      expect(result).to eq(['Task 1', 'Task 2', 'Task 3'])
    end

    it 'supports size and length' do
      expect(subject.size).to eq(3)
      expect(subject.length).to eq(3)
    end
  end

  describe '#offset' do
    it 'returns collection with offset applied' do
      result = subject.offset(1)
      expect(result.to_a).to eq([task2, task3])
    end
  end

  describe '#limit' do
    it 'returns collection with limit applied' do
      result = subject.limit(2)
      expect(result.to_a).to eq([task1, task2])
    end
  end

  describe '#slice' do
    it 'returns collection with slice applied' do
      result = subject.slice(1, 2)
      expect(result.to_a).to eq([task2, task3])
    end

    it 'handles out of bounds slices' do
      result = subject.slice(10, 5)
      expect(result.to_a).to eq([])
    end
  end

  describe '#first and #last' do
    it 'returns first and last elements' do
      expect(subject.first).to eq(task1)
      expect(subject.last).to eq(task3)
    end
  end

  describe '#cursor_for' do
    it 'returns index-based cursor for item' do
      cursor = subject.cursor_for(task2)
      expect(cursor).to eq('1')
    end

    it 'returns nil for non-existent item' do
      non_existent_task = Task.create(title: 'Other', description: 'Not in collection')
      cursor = subject.cursor_for(non_existent_task)
      expect(cursor).to be_nil
    end
  end

  describe '#empty?' do
    it 'returns false for non-empty collection' do
      expect(subject.empty?).to be false
    end

    it 'returns true for empty collection' do
      empty_collection = described_class.new([])
      expect(empty_collection.empty?).to be true
    end
  end
end