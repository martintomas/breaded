# frozen_string_literal: true

class Seeds::FillOrders
  def self.perform_for(orders)
    orders.each do |order|
      order[:user] = User.find_by! email: order[:user]
      next if Order.where(user: order[:user], delivery_date_from: order[:delivery_date]).exists?

      puts "order: #{order[:user]} - #{order[:delivery_date]}"
      order_obj = Order.new subscription_period: subscription_period_for(order),
                            user: order[:user],
                            delivery_date_from: order[:delivery_date],
                            delivery_date_to: order[:delivery_date] + 4.hours,
                            position: 1
      order_obj.build_address order[:address]
      order_foods_for order_obj, order[:foods]
      order_states_for order_obj, order[:states]
      build_surprises_for order_obj, order[:surprises]
      order_obj.save!
    end
  end

  def self.subscription_period_for(data)
    subscription = Subscription.find_by!(user: data[:user], active: true)
    subscription.subscription_periods.first || subscription.subscription_periods.create!(started_at: data[:delivery_date],
                                                                                         ended_at: data[:delivery_date] + 1.month)
  end

  def self.order_states_for(order, states)
    states.each do |order_state|
      order.order_state_relations.build order_state: OrderState.find_by!(code: order_state)
    end
  end

  def self.order_foods_for(order, foods)
    foods.each do |order_food|
      food = Food.joins(name: :text_translations).find_by! text_translations: { text: order_food[:name] }
      order.order_foods.build food: food, amount: order_food[:amount], automatic: false
    end
  end

  def self.build_surprises_for(order, values)
    return if values.blank?

    values.each do |surprise|
      tag = Tag.joins(name: :text_translations).find_by! text_translations: { text: surprise[:tag][:name] }, tag_type: surprise[:tag][:tag_type]
      order.order_surprises.build tag: tag, amount: surprise[:amount]
    end
  end
end
