# frozen_string_literal: true

ActiveAdmin.register Producer do
  config.filters = false

  menu parent: I18n.t('active_admin.menu.parents.producer'), priority: 1, label: I18n.t('active_admin.producers.label')

  permit_params name_attributes: {}, description_attributes: {}

  controller do
    def scoped_collection
      end_of_association_chain.with_translations
    end
  end

  index do
    selectable_column
    id_column
    column :name, -> (row_record) { row_record.localized_name }
    column :description, -> (row_record) { row_record.localized_description }
    column :created_at
    column :updated_at
    actions
  end

  show title: proc { |row_record| row_record.localized_name } do
    attributes_table do
      row(:name) { |row_record| row_record.localized_name }
      row(:description) { |row_record| row_record.localized_description }
      row :created_at
      row :updated_at
    end
  end

  form partial: 'form'
end
