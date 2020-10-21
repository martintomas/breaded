# frozen_string_literal: true

ActiveAdmin.register Order do
  config.filters = false

  menu parent: I18n.t('active_admin.menu.parents.order'), priority: 1, label: I18n.t('active_admin.orders.label')

  includes subscription_period: { subscription: :user }

  actions :index, :show, :edit, :update, :destroy

  permit_params :user_id, :subscription_period_id, :delivery_date_from, :delivery_date_to, address_attributes: {}

  index do
    selectable_column
    id_column
    column :user
    column :subscription
    column :delivery_date_from
    column :delivery_date_to
    column :created_at
    actions
  end

  show do
    attributes_table do
      row :subscription
      row :subscription_period
      row :user
      row :delivery_date_from
      row :delivery_date_to
      row :created_at
      row :updated_at
    end
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
    panel I18n.t('active_admin.order_surprises.label'), id: 'order_surprises' do
      table_for resource.order_surprises.includes(tag: [:tag_type, name: { text_translations: :language }]) do
        column :tag
        column :tag_type, -> (record_data) { record_data.tag.tag_type }
        column :amount
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
