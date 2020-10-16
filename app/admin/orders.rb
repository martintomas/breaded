# frozen_string_literal: true

ActiveAdmin.register Order do
  config.filters = false

  menu parent: I18n.t('active_admin.menu.parents.order'), priority: 1, label: I18n.t('active_admin.orders.label')

  actions :index, :show, :edit, :update, :destroy

  permit_params :user_id, :subscription_id, :delivery_date, address_attributes: {}

  index do
    selectable_column
    id_column
    column :user
    column :subscription
    column :delivery_date
    column :created_at
    actions
  end

  show do
    default_main_content
    panel I18n.t('active_admin.addresses.label'), id: 'address' do
      table_for resource.address do
        column :address_line
        column :street
        column :postal_code
        column :city
        column :state
      end
    end
    panel I18n.t('active_admin.order_foods.label'), id: 'order_foods' do
      table_for resource.order_foods.includes(food: { name: { text_translations: :language } }) do
        column :food
        column :amount
        column :automatic
      end
    end
    panel I18n.t('active_admin.order_states.label'), id: 'order_states' do
      table_for resource.order_states do
        column :code
      end
    end
  end

  form partial: 'form'
end
