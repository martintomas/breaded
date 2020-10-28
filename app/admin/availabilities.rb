# frozen_string_literal: true

ActiveAdmin.register Availability do
  config.filters = false

  menu parent: I18n.t('active_admin.menu.parents.availability'), priority: 4, label: I18n.t('active_admin.availabilities.label')

  permit_params :time_from, :time_to, :day_in_week

  index do
    selectable_column
    id_column
    column :day_in_week
    column :time_from, -> (row_record) { row_record.time_from.strftime( "%H:%M") }
    column :time_to, -> (row_record) { row_record.time_to.strftime( "%H:%M") }
    column :created_at
    actions
  end

  show do
    attributes_table do
      row(:day_in_week)
      row(:time_from) { |row_record| row_record.time_from.strftime( "%H:%M") }
      row(:time_to) { |row_record| row_record.time_to.strftime( "%H:%M") }
      row :created_at
      row :updated_at
    end
  end
end
