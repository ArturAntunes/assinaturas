class User < ApplicationRecord
  has_secure_password

  # Enums
  enum role: { customer: 0, admin: 1 }

  # Associations
  has_many :subscriptions, dependent: :destroy
  has_many :plans, through: :subscriptions

  # Validations
  validates :name, presence: true
  validates :email, presence: true, uniqueness: { case_sensitive: false }
  validates :email, format: { with: URI::MailTo::EMAIL_REGEXP }
  validates :password, length: { minimum: 6 }, if: -> { new_record? || password.present? }

  # Callbacks
  before_create :generate_api_token

  # Scopes
  scope :admins, -> { where(role: :admin) }
  scope :customers, -> { where(role: :customer) }

  def active_subscription
    subscriptions.active.first
  end

  def has_active_subscription?
    active_subscription.present?
  end

  private

  def generate_api_token
    self.api_token = SecureRandom.hex(20) if api_token.blank?
  end
end
