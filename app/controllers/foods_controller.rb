# frozen_string_literal: true

class FoodsController < ApplicationController
  def index
    respond_to do |format|
      format.html
      format.json {
        return list_of_breads_for(params[:category]) if params[:section] == 'breads'
        list_of_bakers_for(params[:category])
      }
    end
  end

  def surprise_me; end

  def show
    @food = Food.with_translations.preload(tags: { name: { text_translations: :language } },
                                           producer: { name: { text_translations: :language } }).find params[:id]
  end

  private

  def list_of_breads_for(category)
    query = Food.with_translations.preload(tags: { name: { text_translations: :language } })
    query = query.joins(:tags).where(tags: { id: category }) if category.present? && category != 'all'

    pagy, foods = pagy query, items: 10
    render json: { header: render_to_string(partial: 'foods/index/food_details_header', locals: { query: query }, formats: [:html]),
                   entries: render_to_string(partial: 'foods/index/food_details', locals: { foods: foods }, formats: [:html]),
                   pagination: view_context.pagy_nav(pagy) }
  end

  def list_of_bakers_for(category)
    query = Producer.with_translations.preload(foods: { tags: { name: { text_translations: :language } } }).order(:id)
    query = query.where(id: category) if category.present? && category != 'all'

    pagy, producers = pagy query, items: 5
    render json: { entries: render_to_string(partial: 'foods/index/producer_details', locals: { producers: producers }, formats: [:html]),
                   pagination: view_context.pagy_nav(pagy) }
  end
end
