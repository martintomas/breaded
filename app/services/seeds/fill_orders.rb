# frozen_string_literal: true

class Seeds::FillOrders
  def self.perform_for(orders)
    orders.each do |order|
      order[:user] = User.find_by! email: order[:user]
      next if Order.where(user: order[:user], delivery_date: order[:delivery_date]).exists?

      puts "order: #{order[:user]} - #{order[:delivery_date]}"
      order_obj = Order.new subscription: Subscription.find_by!(user: order[:user], active: true),
                            user: order[:user],
                            delivery_date: order[:delivery_date]
      order_obj.build_address order[:address]
      order_foods_for order_obj, order[:foods]
      order_states_for order_obj, order[:states]
      order_obj.save!
    end
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
end
