# frozen_string_literal: true

class FoodsController < ApplicationController
  skip_before_action :authenticate_user!

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
    authorize! :read, @food
  end

  private

  def list_of_breads_for(category)
    query = Food.with_translations.preload(tags: { name: { text_translations: :language } })
    query = query.joins(:tags).where(tags: { id: category }) if category.present? && category != 'all'
    query = query.accessible_by current_ability

    pagy, foods = pagy query, items: 10
    render json: { header: render_to_string(partial: 'foods/index/food_details_header', locals: { query: query }, formats: [:html]),
                   entries: render_to_string(partial: 'foods/index/food_details',
                                             locals: { foods: foods, basket_prefix: params[:basket_prefix], root_url: params[:root_url] },
                                             formats: [:html]),
                   pagination: view_context.pagy_nav(pagy) }
  end

  def list_of_bakers_for(category)
    query = Producer.with_translations.preload(foods: { tags: { name: { text_translations: :language } } }).order(:id)
    query = query.where(id: category) if category.present? && category != 'all'
    query = query.accessible_by current_ability

    pagy, producers = pagy query, items: 5
    render json: { entries: render_to_string(partial: 'foods/index/producer_details',
                                             locals: { producers: producers, basket_prefix: params[:basket_prefix], root_url: params[:root_url] },
                                             formats: [:html]),
                   pagination: view_context.pagy_nav(pagy) }
  end
end
