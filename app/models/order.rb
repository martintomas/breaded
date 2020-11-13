# frozen_string_literal: true

class Order < ApplicationRecord
  belongs_to :subscription_period
  belongs_to :user
  belongs_to :copied_order, class_name: 'Order', optional: true
  belongs_to :unconfirmed_copied_order, class_name: 'Order', optional: true

  has_many :order_foods, dependent: :destroy
  has_many :order_state_relations, dependent: :destroy
  has_many :order_states, through: :order_state_relations
  has_many :order_surprises, dependent: :destroy
  has_one :address, as: :addressable, dependent: :destroy

  accepts_nested_attributes_for :address

  validates :delivery_date_from, :delivery_date_to, :position, presence: true

  delegate :subscription, to: :subscription_period

  def delivered?
    delivery_date_to <= Time.current
  end

  def delivery_date
    "#{delivery_date_from.strftime('%l:%M %P')} - #{delivery_date_to.strftime('%l:%M %P')}, #{delivery_date_to.strftime('%e %B')}"
  end

  def editable_till
    (delivery_date_from - Rails.application.config.options[:locked_before_delivery].days).end_of_day
  end

  def editable?
    !finalised?
  end

  def placed?
    order_states.map(&:id).include? OrderState.the_order_placed.id
  end

  def finalised?
    order_states.map(&:id).include? OrderState.the_finalised.id
  end
end
