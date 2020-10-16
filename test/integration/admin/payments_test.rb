# frozen_string_literal: true

require 'test_helper'

class Admin::PaymentsTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers

  setup do
    sign_in users(:admin)
    @payment = payments :payment_1
  end

  test 'is shown at menu' do
    get admin_payments_url
    assert_select 'div.header' do
      assert_select 'li.menu_item.current' do
        assert_select 'a', I18n.t('active_admin.menu.parents.order')
        assert_select 'ul.menu' do
          assert_select 'li', I18n.t('active_admin.payments.label')
        end
      end
    end
  end

  test 'shows proper title' do
    get admin_payments_url
    assert_select 'div.title_bar' do
      assert_select 'h2#page_title', I18n.t('active_admin.payments.label')
    end
  end

  test '#index' do
    get admin_payments_url
    assert_select 'div#active_admin_content' do
      assert_select 'div#main_content' do
        assert_select 'div.paginated_collection' do
          assert_select 'table#index_table_payments' do
            Payment.all.each do |payment|
              assert_select 'tr' do
                assert_select 'td', payment.subscription.to_s
                assert_select 'td', payment.currency.to_s
                assert_select 'td', payment.price.to_s
              end
            end
          end
        end
      end
    end
  end

  test '#show' do
    get admin_payment_url(@payment)
    assert_select 'div.title_bar' do
      assert_select 'h2#page_title', "Payment ##{@payment.id}"
    end
    assert_select 'div#active_admin_content' do
      assert_select 'div#main_content' do
        assert_select 'div.panel' do
          assert_select 'table' do
            assert_select 'td', @payment.subscription.to_s
            assert_select 'td', @payment.currency.to_s
            assert_select 'td', @payment.price.to_s
          end
        end
      end
    end
  end
end
