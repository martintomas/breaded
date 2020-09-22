# frozen_string_literal: true

ActiveAdmin.register User do
  menu parent: I18n.t('active_admin.menu.parents.user'), priority: 1, label: I18n.t('active_admin.users.label')

  filter :first_name_or_last_name_cont, as: :string, label: I18n.t('active_admin.users.name')
  filter :email_contains, as: :string, label: I18n.t('active_admin.users.email')

  permit_params :first_name, :last_name, :email, :password, role_ids: []

  show do
    default_main_content
    panel I18n.t('active_admin.roles.label'), id: 'roles' do
      table_for resource.roles do
        column :name
      end
    end
    panel I18n.t('active_admin.users.address'), id: 'address' do
      table_for resource.address do
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
