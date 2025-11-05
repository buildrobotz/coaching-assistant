class CourseModule < ApplicationRecord
  has_many :lessons, dependent: :destroy
  has_many :enrollment_modules, dependent: :destroy

  validates :name, presence: true
  validates :position, presence: true, numericality: { only_integer: true }

  default_scope { order(position: :asc) }
end
