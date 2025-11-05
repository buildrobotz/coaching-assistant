class ClientEnrollment < ApplicationRecord
  belongs_to :client
  has_many :enrollment_modules, dependent: :destroy
  has_many :course_modules, through: :enrollment_modules

  validates :client, presence: true
end
