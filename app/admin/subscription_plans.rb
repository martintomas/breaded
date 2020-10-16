# frozen_string_literal: true

ActiveAdmin.register SubscriptionPlan do
  config.filters = false

  includes :currency

  menu parent: I18n.t('active_admin.menu.parents.order'), priority: 3, label: I18n.t('active_admin.subscription_plans.label')

  permit_params :currency_id, :price, :number_of_deliveries
end
