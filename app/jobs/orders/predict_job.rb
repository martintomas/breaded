# frozen_string_literal: true

module Orders
  class PredictJob < ApplicationJob
    queue_as :default

    def perform(subscription, delivery_date_from, delivery_date_to)

    end
  end
end
