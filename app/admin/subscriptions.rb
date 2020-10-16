# frozen_string_literal: true

ActiveAdmin.register Subscription do
  menu parent: I18n.t('active_admin.menu.parents.order'), priority: 2, label: I18n.t('active_admin.subscriptions.label')

  includes :user, subscription_plan: :currency

  filter :subscription_plan
  filter :active

  actions :index, :show, :edit, :update

  permit_params :user_id, :subscription_plan_id, :active, :number_of_orders_left, :number_of_items

  index do
    selectable_column
    id_column
    column :user
    column :subscription_plan
    column :active
    column :number_of_orders_left
    actions
  end

  show do
    default_main_content
    panel I18n.t('active_admin.subscription_surprises.label'), id: 'subscription_surprises' do
      table_for resource.subscription_surprises.includes(tag: [:tag_type, name: { text_translations: :language }]) do
        column :tag
        column :tag_type, -> (record_data) { record_data.tag.tag_type }
        column :amount
      end
    end
    panel I18n.t('active_admin.orders.label'), id: 'orders' do
      table_for resource.orders do
        column :delivery_date
        column :created_at
        column :detail, -> (row_data) { link_to(I18n.t('active_admin.dashboards.see_detail'), admin_order_path(row_data[:id])) }
      end
    end
    panel I18n.t('active_admin.payments.label'), id: 'payments' do
      table_for resource.payments.includes(:currency) do
        column :price
        column :currency
        column :created_at
        column :detail, -> (row_data) { link_to(I18n.t('active_admin.dashboards.see_detail'), admin_payment_path(row_data[:id])) }
      end
    end
  end
end
