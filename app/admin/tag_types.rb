# frozen_string_literal: true

ActiveAdmin.register TagType do
  config.filters = false

  menu parent: I18n.t('active_admin.menu.parents.tag'), priority: 2, label: I18n.t('active_admin.tag_types.label')

  permit_params :code

  index do
    selectable_column
    id_column
    column :code
    column :created_at
    column :updated_at
    actions
  end

  show do
    attributes_table do
      row :code
      row :created_at
      row :updated_at
    end
  end
end
