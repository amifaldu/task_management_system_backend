require 'rails_helper'

RSpec.describe Task, type: :model do
  describe '.create' do
    it 'creates a valid task with default status' do
      task = Task.create(title: 'Test', description: 'RSpec test case')
      expect(task).to be_valid
      expect(task.status).to eq(Task::STATUS_TO_DO)
    end

    it 'fails without a title' do
      task = Task.create(description: 'Missing title')
      expect(task).not_to be_valid
      expect(task.errors[:title]).to include(I18n.t('errors.messages.title_required'))
    end

    it 'fails with invalid status' do
      task = Task.create(title: 'Invalid', description: 'Bad status', status: 'Unknown')
      expect(task).not_to be_valid
      expect(task.errors[:status]).to include(I18n.t('errors.messages.invalid_status'))
    end
  end

  describe '.find_by_id' do
    it 'returns the correct task by ID' do
      task = Task.create(title: 'Find me', description: 'Locate by ID')
      found = Task.find_by_id(task.id)
      expect(found).to eq(task)
    end
  end

  describe '.update' do
    it 'updates a task successfully' do
      task = Task.create(title: 'Old', description: 'Old desc')
      result = Task.update(task.id, title: 'New', description: 'New desc')
      expect(result[:task].title).to eq('New')
      expect(result[:errors]).to be_empty
    end

    it 'returns error for invalid update' do
      task = Task.create(title: 'Valid', description: 'Valid desc')
      result = Task.update(task.id, title: '', description: '')
      expect(result[:task]).to be_nil
      expect(result[:errors].map { |e| e[:field] }).to include('title', 'description')
    end
  end

  describe '.delete' do
    it 'deletes a task successfully' do
      task = Task.create(title: 'Delete me', description: 'To be removed')
      result = Task.delete(task.id)
      expect(result[:success]).to be true
      expect(Task.find_by_id(task.id)).to be_nil
    end

    it 'returns error for missing task' do
      result = Task.delete('non-existent-id')
      expect(result[:success]).to be false
      expect(result[:errors].first[:field]).to eq('id')
    end
  end

  describe '.filter' do
    it 'returns tasks filtered by status' do
      Task.create(title: 'A', description: 'A desc', status: Task::STATUS_DONE)
      Task.create(title: 'B', description: 'B desc', status: Task::STATUS_TO_DO)
      done_tasks = Task.filter(status: Task::STATUS_DONE)
      expect(done_tasks.all? { |t| t.status == Task::STATUS_DONE }).to be true
    end
  end
end
