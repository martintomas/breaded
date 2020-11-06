# frozen_string_literal: true

require 'test_helper'

class SubscriptionPeriodsHelperTest < ActionView::TestCase
  test '.box_number_for' do
    order_1 = orders :customer_order_1
    order_2 = orders :customer_order_2

    assert_equal 1, box_number_for(order_1, [order_1, order_2])
    assert_equal 2, box_number_for(order_2, [order_1, order_2])
  end

  test '.boxes_names_for' do
    order_1 = orders :customer_order_1
    order_2 = orders :customer_order_2

    assert_equal I18n.t("app.users.show.boxes_names.box_1"), boxes_names_for(order_1, [order_1, order_2])
    assert_equal I18n.t("app.users.show.boxes_names.box_2"), boxes_names_for(order_2, [order_1, order_2])
  end

  test '.order_due_date_for' do
    order_1 = orders :customer_order_1
    order_2 = orders :customer_order_2
    order_3 = orders :customer_order_3

    inner_text = I18n.t('app.users.show.order_till', box: boxes_names_for(order_2, [order_1, order_2, order_3]), date: order_2.editable_till.strftime('%A, %d %b')) + ' ' +
      link_to('ⓘ', '#info', class: 'info', data: { action: 'subscription-periods--my-box#open' })
    assert_equal content_tag(:span, inner_text.html_safe, class: 'listStyle redListStyle'), order_due_date_for([order_1, order_2, order_3])
  end

  test '.order_due_date_for - placed orders are ignored' do
    order_1 = orders :customer_order_1
    order_2 = orders :customer_order_2
    order_2.order_state_relations.create! order_state: order_states(:order_placed)
    order_3 = orders :customer_order_3

    inner_text = I18n.t('app.users.show.order_till', box: boxes_names_for(order_3, [order_1, order_2, order_3]), date: order_3.editable_till.strftime('%A, %d %b')) + ' ' +
        link_to('ⓘ', '#info', class: 'info', data: { action: 'subscription-periods--my-box#open' })
    assert_equal content_tag(:span, inner_text.html_safe, class: 'listStyle redListStyle'), order_due_date_for([order_1, order_2, order_3])
  end

  test '.order_due_date_for - no orders' do
    assert_nil order_due_date_for([])
  end
end
