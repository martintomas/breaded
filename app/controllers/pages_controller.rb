# frozen_string_literal: true

class PagesController < ApplicationController
  def home; end

  def commit
    render file: 'public/commit.txt', layout: false
  end
end
