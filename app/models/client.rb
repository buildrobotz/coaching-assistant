class Client < ApplicationRecord
  has_many :client_enrollments, dependent: :destroy
  has_many :lesson_deliveries, dependent: :destroy
  has_many :daily_completions, dependent: :destroy

  validates :name, presence: true
  validates :email, presence: true, uniqueness: true, format: { with: URI::MailTo::EMAIL_REGEXP }
  validates :timezone, presence: true
  validates :preferred_send_time, presence: true
end
