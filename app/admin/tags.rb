# frozen_string_literal: true

ActiveAdmin.register Tag do
  menu parent: I18n.t('active_admin.menu.parents.tag'), priority: 1, label: I18n.t('active_admin.tags.label')

  filter :tag_type

  permit_params :tag_type_id, name_attributes: {}

  controller do
    def scoped_collection
      end_of_association_chain.with_translations
    end
  end

  index do
    selectable_column
    id_column
    column :name, -> (row_record) { row_record.localized_name }
    column :tag_type
    column :created_at
    column :updated_at
    actions
  end

  show title: proc { |row_record| row_record.localized_name } do
    attributes_table do
      row(:name) { |row_record| row_record.localized_name }
      row :tag_type
      row :created_at
      row :updated_at
    end
  end

  form partial: 'form'
end
