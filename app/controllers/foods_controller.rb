# frozen_string_literal: true

class FoodsController < ApplicationController
  def index
    respond_to do |format|
      format.html
      format.json {
        return render_breads if params[:section] == 'breads'
        render_bakers
      }
    end
  end

  private

  def render_breads
    query = Food.with_translations.preload(tags: { name: { text_translations: :language } })
    query = query.joins(:tags).where(tags: { id: params[:category]}) if params[:category].present? && params[:category] != 'all'

    pagy, foods = pagy query, items: 10
    render json: { header: render_to_string(partial: 'food_details_header', locals: { query: query }, formats: [:html]),
                   entries: render_to_string(partial: 'food_details', locals: { foods: foods }, formats: [:html]),
                   pagination: view_context.pagy_nav(pagy) }
  end

  def render_bakers
    query = Producer.with_translations.preload(foods: { tags: { name: { text_translations: :language } } }).order(:id)
    query = query.where(id: params[:category]) if params[:category].present? && params[:category] != 'all'

    pagy, producers = pagy query, items: 5
    render json: { entries: render_to_string(partial: 'producer_details', locals: { producers: producers }, formats: [:html]),
                   pagination: view_context.pagy_nav(pagy) }
  end
end
