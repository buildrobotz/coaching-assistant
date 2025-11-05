class DailyCompletion < ApplicationRecord
  belongs_to :client

  validates :completion_date, presence: true
  validates :lessons_completed_count, presence: true, numericality: { only_integer: true, greater_than_or_equal_to: 0, less_than_or_equal_to: 3 }

  def can_add_lesson?
    lessons_completed_count < 3
  end

  def increment_lesson_count!
    return false unless can_add_lesson?

    increment!(:lessons_completed_count)
  end
end
