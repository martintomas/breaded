# frozen_string_literal: true

ActiveAdmin.register Order do
  config.filters = false

  menu parent: I18n.t('active_admin.menu.parents.order'), priority: 1, label: I18n.t('active_admin.orders.label')
end
