# frozen_string_literal: true

ActiveAdmin.register ProducerApplication do
  config.filters = false

  actions :index, :show, :destroy

  menu parent: I18n.t('active_admin.menu.parents.producer'), priority: 2, label: I18n.t('active_admin.producer_applications.label')

  show do
    default_main_content
    panel I18n.t('active_admin.tags.categories'), id: 'tags' do
      table_for resource.tags.with_translations do
        column :localized_name
      end
    end
  end
end
