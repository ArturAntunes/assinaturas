class Subscription < ApplicationRecord
  # Enums
  enum status: { pending: 0, active: 1, canceled: 2 }

  # Associations
  belongs_to :user
  belongs_to :plan
  has_many :invoices, dependent: :destroy

  # Validations
  validates :user, presence: true
  validates :plan, presence: true
  validates :status, presence: true
  validate :only_one_active_subscription_per_user, if: :active?

  # Scopes
  scope :active, -> { where(status: :active) }
  scope :pending, -> { where(status: :pending) }
  scope :canceled, -> { where(status: :canceled) }

  # Instance Methods
  def activate!
    return false if user.has_active_subscription?

    transaction do
      update!(status: :active, started_at: Time.current)
      generate_first_invoice
    end
  end

  def cancel!
    return false unless active?

    update!(status: :canceled, canceled_at: Time.current)
  end

  def generate_first_invoice
    Invoices::GenerateService.call(subscription: self, reference_date: Time.current)
  end

  def generate_next_invoice
    return unless active?

    Invoices::GenerateService.call(subscription: self, reference_date: Time.current)
  end

  private

  def only_one_active_subscription_per_user
    if user.subscriptions.active.where.not(id: id).exists?
      errors.add(:base, 'Usuário já possui uma assinatura ativa')
    end
  end
end
