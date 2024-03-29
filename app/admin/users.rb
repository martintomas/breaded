# frozen_string_literal: true

ActiveAdmin.register User do
  menu parent: I18n.t('active_admin.menu.parents.user'), priority: 1, label: I18n.t('active_admin.users.label')

  filter :first_name_or_last_name_cont, as: :string, label: I18n.t('active_admin.users.name')
  filter :email_contains, as: :string, label: I18n.t('active_admin.users.email')

  permit_params :first_name, :last_name, :email, :phone_number, :password, role_ids: []

  index do
    selectable_column
    id_column
    column :first_name
    column :last_name
    column :email
    column :phone_number
    column :created_at
    column :updated_at
    actions
  end

  show do
    default_main_content
    panel I18n.t('active_admin.roles.label'), id: 'roles' do
      table_for resource.roles do
        column :name
      end
    end
    panel I18n.t('active_admin.users.addresses'), id: 'addresses' do
      table_for resource.addresses do
        column :address_line
        column :street
        column :postal_code
        column :city
        column :state
      end
    end
  end

  form partial: 'form'
end
