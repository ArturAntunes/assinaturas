class Invoice < ApplicationRecord
  # Enums
  enum status: { open: 0, paid: 1, expired: 2 }

  # Associations
  belongs_to :subscription

  # Validations
  validates :subscription, presence: true
  validates :reference_month, presence: true
  validates :amount_cents, presence: true, numericality: { greater_than: 0 }
  validates :due_on, presence: true
  validates :status, presence: true
  validate :unique_invoice_per_month

  # Scopes
  scope :open, -> { where(status: :open) }
  scope :paid, -> { where(status: :paid) }
  scope :expired, -> { where(status: :expired) }
  scope :overdue, -> { where(status: :open).where('due_on < ?', Date.current) }
  scope :by_month, ->(month) { where(reference_month: month.beginning_of_month) }

  # Callbacks
  after_create :check_expiration

  # Instance Methods
  def pay!
    return false unless can_be_paid?

    update!(status: :paid, paid_at: Time.current)
  end
  
  def can_be_paid?
    open? && subscription.active?
  end

  def mark_as_expired!
    return false unless open?

    update!(status: :expired) if overdue?
  end

  def overdue?
    open? && due_on < Date.current
  end

  def amount_in_reais
    (amount_cents / 100.0).round(2)
  end

  def formatted_amount
    "R$ #{format('%.2f', amount_in_reais)}"
  end

  def user
    subscription.user
  end

  private

  def unique_invoice_per_month
    if subscription && reference_month
      existing = Invoice.where(
        subscription_id: subscription_id,
        reference_month: reference_month.beginning_of_month
      ).where.not(id: id)

      if existing.exists?
        errors.add(:reference_month, 'já possui fatura para este mês')
      end
    end
  end

  def check_expiration
    mark_as_expired! if overdue?
  end
end
