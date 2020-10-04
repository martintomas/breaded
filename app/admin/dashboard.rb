ActiveAdmin.register_page "Dashboard" do
  menu priority: 1, label: proc { I18n.t("active_admin.dashboard") }

  content title: proc { I18n.t("active_admin.dashboard") } do
    columns do
      column do
        panel I18n.t('active_admin.dashboards.panels.recent_applications') do
          table_for ProducerApplication.order(:created_at).first(5) do
            column :first_name
            column :last_name
            column :email
            column :phone_number
            column :detail, -> (row_data) { link_to(I18n.t('active_admin.dashboards.see_detail'),
                                                    admin_producer_application_path(row_data[:id])) }
          end
        end
      end
    end
  end
end
