# frozen_string_literal: true

module SubscriptionPeriodsHelper
  def boxes_names_for(order)
    I18n.t("app.users.show.boxes_names.box_#{order.position}")
  end

  def order_due_date_for(orders)
    order = orders.reject(&:placed?).detect { |order| order.delivery_date_from >= Time.current }
    return if order.blank?

    inner_text = I18n.t('app.users.show.order_till', box: boxes_names_for(order), date: order.editable_till.strftime('%A, %d %b')) + ' ' +
      link_to('ⓘ', '#info', class: 'info', data: { action: 'subscription-periods--my-box#open' })
    content_tag :span, inner_text.html_safe, class: 'listStyle redListStyle'
  end
end
