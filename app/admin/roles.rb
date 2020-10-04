# frozen_string_literal: true

ActiveAdmin.register Role do
  config.filters = false

  menu parent: I18n.t('active_admin.menu.parents.user'), priority: 2, label: I18n.t('active_admin.roles.label')

  permit_params :name, :resource_type, :resource_id

  index do
    selectable_column
    id_column
    column :name
    column :created_at
    column :updated_at
    actions
  end

  show do
    attributes_table do
      row :name
      row :created_at
      row :updated_at
    end
  end

  form partial: 'form'
end
