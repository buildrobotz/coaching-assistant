class EnrollmentModule < ApplicationRecord
  belongs_to :client_enrollment
  belongs_to :course_module

  validates :position, presence: true, numericality: { only_integer: true }

  default_scope { order(position: :asc) }
end
