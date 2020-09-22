# frozen_string_literal: true

ActiveAdmin.register Role do
  config.filters = false

  menu parent: I18n.t('active_admin.menu.parents.user'), priority: 2, label: I18n.t('active_admin.roles.label')

  permit_params :name, :resource_type, :resource_id
end
