# frozen_string_literal: true

module SubscriptionPeriodsHelper
  def box_number_for(order, orders)
    orders.index(order) + 1
  end

  def boxes_names_for(order, orders)
    I18n.t("app.users.show.boxes_names.box_#{box_number_for(order, orders)}")
  end

  def order_due_date_for(orders)
    order = orders.detect { |order| order.delivery_date_from >= Time.current }
    return if order.blank?

    inner_text = I18n.t('app.users.show.order_till', box: boxes_names_for(order, orders), date: order.editable_till.strftime('%A, %d %b')) + ' ' +
        link_to('ⓘ', '#info', class: 'info', data: { action: 'subscription-periods--my-box#open' })
    content_tag :span, inner_text.html_safe, class: 'listStyle redListStyle'
  end
end
