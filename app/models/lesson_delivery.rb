class LessonDelivery < ApplicationRecord
  belongs_to :client
  belongs_to :lesson

  validates :status, presence: true, inclusion: { in: %w[pending sent completed] }

  before_create :generate_completion_token

  scope :pending, -> { where(status: 'pending') }
  scope :sent, -> { where(status: 'sent') }
  scope :completed, -> { where(status: 'completed') }
  scope :ready_to_send, -> { pending.where('scheduled_for <= ?', Time.current) }

  def mark_completed!
    update!(status: 'completed', completed_at: Time.current)
  end

  def mark_sent!
    update!(status: 'sent', sent_at: Time.current)
  end

  private

  def generate_completion_token
    self.completion_token = SecureRandom.urlsafe_base64(32)
  end
end
