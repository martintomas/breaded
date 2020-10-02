# frozen_string_literal: true

require 'test_helper'

class ProducerApplicationsTest < ActionDispatch::IntegrationTest
  setup do
    get new_producer_application_path
  end

  test '#new - it contains form' do
    assert_select 'form.bakersignup-form' do
      assert_select 'h1#title-bakersignup', I18n.t('app.baker_signup.apply_to_be_baker')
      assert_select 'p', I18n.t('app.baker_signup.description')
      assert_select 'section' do
        assert_select 'fieldset#bakersignup-fieldset' do
          assert_select "label[for=producer_application_first_name]"
          assert_select 'input#producer_application_first_name'
          assert_select "label[for=producer_application_last_name]"
          assert_select 'input#producer_application_last_name'
          assert_select "label[for=producer_application_email]"
          assert_select 'input#producer_application_email'
          assert_select "label[for=producer_application_phone_number]"
          assert_select 'input#producer_application_phone_number'
        end
        assert_select 'div.checkBoxSection' do
          Tag.categories.with_translations.each do |tag|
            assert_select "label[for='producer_application_tag_ids_#{tag.id}']", tag.localized_name
          end
        end
        assert_select "input.bakersignup_form[type='submit'][value=?]", 'Submit'
      end
    end
  end
end
