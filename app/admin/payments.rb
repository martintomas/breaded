# frozen_string_literal: true

ActiveAdmin.register Payment do
  config.filters = false

  includes :currency, subscription_period: { subscription: :user }

  actions :index, :show

  menu parent: I18n.t('active_admin.menu.parents.order'), priority: 4, label: I18n.t('active_admin.payments.label')

  show do
    attributes_table do
      row :subscription
      row :subscription_period
      row :price
      row :currency
      row :created_at
      row :updated_at
    end
  end
end
