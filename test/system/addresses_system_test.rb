# frozen_string_literal: true

require "application_system_test_case"

class AddressesSystemTest < ApplicationSystemTestCase
  setup do
    login_as_customer
    @user = users :customer
    @address = @user.address
  end

  test '#new' do
    @user.addresses.destroy_all

    visit addresses_path
    find('div.new-address-content span.circle').click
    assert_selector 'h3.title', text: I18n.t('app.addresses.new.title')

    within 'form#new_address' do
      fill_in 'address[address_line]', with: 'New Address Line'
      fill_in 'address[street]', with: 'New Street'
      fill_in 'address[city]', with: 'New City'
      fill_in 'address[postal_code]', with: 'New Postal Code'
      select_dropdown_with address_types(:friends_home)
      click_button I18n.t('app.addresses.new.submit')
    end

    assert_selector 'h3.title', text: I18n.t('app.addresses.index.title')
    within '.address-content' do
      assert_selector 'div.address-line', text: 'New Address Line, New Street, New City'
      assert_selector 'div.postal-code', text: 'New Postal Code'
    end
  end

  test '#update' do
    keep_only_default_address!

    visit addresses_path
    find("span.address-edit a[href='#{edit_address_path(@address)}']").click
    assert_selector 'h3.title', text: I18n.t('app.addresses.edit.title')

    within "form#edit_address_#{@address.id}" do
      fill_in 'address[address_line]', with: 'New Address Line'
      fill_in 'address[street]', with: 'New Street'
      fill_in 'address[city]', with: 'New City'
      fill_in 'address[postal_code]', with: 'New Postal Code'
      select_dropdown_with address_types(:friends_home)
      click_button I18n.t('app.addresses.new.submit')
    end

    assert_selector 'h3.title', text: I18n.t('app.addresses.index.title')
    within '.address-content' do
      assert_selector 'div.address-line', text: 'New Address Line, New Street, New City'
      assert_selector 'div.postal-code', text: 'New Postal Code'
    end
  end

  test '#destroy' do
    keep_only_default_address!

    visit addresses_path
    assert_selector 'h3.title', text: I18n.t('app.addresses.index.title')
    assert_selector 'span.section-title', text: I18n.t('app.addresses.index.default_address')

    find("span.address-delete a[href='#{address_path(@address)}']").click
    assert_selector 'h3.title', text: I18n.t('app.addresses.index.title')
    assert_selector 'span.section-title', text: I18n.t('app.addresses.index.default_address'), count: 0
  end

  test '#set_as_main' do
    not_default_address = @user.addresses.where.not(id: @address.id).first

    visit addresses_path
    within 'div.address-content.default-address' do
      assert_selector 'div.address-line', text: "#{@address.address_line}, #{@address.street}, #{@address.city}"
      assert_selector 'div.postal-code', text: @address.postal_code
    end

    find("a.address-default[href='#{set_as_main_address_path(not_default_address)}']").click

    within 'div.address-content.default-address' do
      assert_selector 'div.address-line', text: "#{not_default_address.address_line}, #{not_default_address.street}, #{not_default_address.city}"
      assert_selector 'div.postal-code', text: not_default_address.postal_code
    end
  end

  private

  def keep_only_default_address!
    @user.addresses.where.not(id: @address.id).destroy_all
  end

  def select_dropdown_with(value)
    find('.drop-down .selected').click
    within '.options ul ' do
      find('li', text: value.to_s).click
    end
  end
end
