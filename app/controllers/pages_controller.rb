# frozen_string_literal: true

class PagesController < ApplicationController
  skip_before_action :authenticate_user!, only: %i[about home]

  def about; end

  def faq; end

  def home; end
end
