# frozen_string_literal: true

ActiveAdmin.register Payment do
  config.filters = false

  includes :currency, subscription: :user

  actions :index, :show

  menu parent: I18n.t('active_admin.menu.parents.order'), priority: 4, label: I18n.t('active_admin.payments.label')
end
