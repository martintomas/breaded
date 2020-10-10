# frozen_string_literal: true

ActiveAdmin.register Food do
  config.filters = false

  menu parent: I18n.t('active_admin.menu.parents.producer'), priority: 2, label: I18n.t('active_admin.foods.label')

  permit_params :image, :producer_id, name_attributes: {}, description_attributes: {}, tag_ids: []

  controller do
    def scoped_collection
      end_of_association_chain.with_translations.includes(producer: { name: { text_translations: :language }})
    end
  end

  index do
    selectable_column
    id_column
    column :name, -> (row_record) { row_record.localized_name }
    column :description, -> (row_record) { row_record.localized_description }
    column :producer
    column :created_at
    column :updated_at
    actions
  end

  show title: proc { |row_record| row_record.localized_name } do
    attributes_table do
      row(:name) { |row_record| row_record.localized_name }
      row(:description) { |row_record| row_record.localized_description }
      row(:producer)
      row(:image_detail) { |row_record| image_tag Blobs::UrlBuilder.new(row_record.image_detail).url }
      row(:image_description) { |row_record| image_tag Blobs::UrlBuilder.new(row_record.image_description).url }
      row :created_at
      row :updated_at
    end
    panel I18n.t('active_admin.tags.categories'), id: 'categories' do
      table_for resource.tags.categories.with_translations do
        column :localized_name
      end
    end
    panel I18n.t('active_admin.tags.attributes'), id: 'attributes' do
      table_for resource.tags.attributes.with_translations do
        column :localized_name
      end
    end
    panel I18n.t('active_admin.tags.ingredients'), id: 'ingredients' do
      table_for resource.tags.ingredients.with_translations do
        column :localized_name
      end
    end
    panel I18n.t('active_admin.tags.goes_wells'), id: 'goes_wells' do
      table_for resource.tags.goes_well.with_translations do
        column :localized_name
      end
    end
  end

  form partial: 'form'
end
