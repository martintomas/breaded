# frozen_string_literal: true

ActiveAdmin.register Faq do
  config.filters = false

  menu parent: I18n.t('active_admin.menu.parents.tag'), priority: 3, label: I18n.t('active_admin.faqs.label')

  permit_params question_attributes: {}, answer_attributes: {}

  controller do
    def scoped_collection
      end_of_association_chain.with_translations
    end
  end

  index do
    selectable_column
    id_column
    column :question, -> (row_record) { row_record.localized_question }
    column :answer, -> (row_record) { row_record.localized_answer }
    column :created_at
    column :updated_at
    actions
  end

  show title: proc { |row_record| row_record.localized_question } do
    attributes_table do
      row(:question) { |row_record| row_record.localized_question }
      row(:answer) { |row_record| row_record.localized_answer }
      row :created_at
      row :updated_at
    end
  end

  form partial: 'form'
end
