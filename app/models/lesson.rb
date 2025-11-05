class Lesson < ApplicationRecord
  belongs_to :course_module
  has_many :lesson_deliveries, dependent: :destroy

  validates :title, presence: true
  validates :markdown_file_path, presence: true
  validates :position, presence: true, numericality: { only_integer: true }

  default_scope { order(position: :asc) }
end
