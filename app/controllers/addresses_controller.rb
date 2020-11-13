# frozen_string_literal: true

class AddressesController < ApplicationController
  before_action :set_address, only: %i[edit update set_as_main destroy]

  def index
    @addresses = current_user.addresses
  end

  def new
    @address = Address.new
  end

  def create
    @address = current_user.addresses.new address_params.merge(main: current_user.address.blank?)
    authorize! :create, @address

    if @address.save
      redirect_to addresses_path
    else
      render :new
    end
  end

  def edit
    authorize! :update, @address
  end

  def update
    @address.assign_attributes address_params
    authorize! :update, @address

    if @address.save
      redirect_to addresses_path
    else
      render :edit
    end
  end

  def destroy
    authorize! :destroy, @address
    if @address.destroy
      redirect_to addresses_path
    else
      render :index, alert: @address.errors.full_messages
    end
  end

  def set_as_main
    authorize! :update, @address
    current_user.addresses.where(main: true).update_all main: false
    @address.update! main: true
    redirect_to addresses_path
  end

  private

  def set_address
    @address = Address.find params[:id]
  end

  def address_params
    params.require(:address).permit(:address_type_id, :address_line, :street, :city, :postal_code)
  end
end
