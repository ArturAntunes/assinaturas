class Plan < ApplicationRecord
  # Enums
  enum periodicity: { monthly: 0, quarterly: 1 }

  # Associations
  has_many :subscriptions, dependent: :restrict_with_error
  has_many :users, through: :subscriptions

  # Validations
  validates :name, presence: true
  validates :price_cents, presence: true, numericality: { greater_than: 0 }
  validates :periodicity, presence: true

  # Scopes
  scope :active, -> { where(active: true) }
  scope :inactive, -> { where(active: false) }

  def price_in_reais
    (price_cents / 100.0).round(2)
  end

  def formatted_price
    "R$ #{format('%.2f', price_in_reais).gsub('.', ',')}"
  end

  def periodicity_in_months
    case periodicity
    when 'monthly'
      1
    when 'quarterly'
      3
    end
  end
end
