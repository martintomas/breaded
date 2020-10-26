# frozen_string_literal: true

module ApplicationHelper
  include Pagy::Frontend

  def required_field
    content_tag(:sup, '*')
  end
end
