# frozen_string_literal: true

require 'test_helper'

class PagesTest < ActionDispatch::IntegrationTest
  include ActionView::Helpers::SanitizeHelper

  setup do
    get root_url
  end

  test '#home - it contains menu' do
    assert_select 'header.header' do
      assert_select 'a.logo'
      assert_select 'ul.menu' do
        assert_select 'li', I18n.t('app.menu.about')
        assert_select 'li', I18n.t('app.menu.gift')
        assert_select 'li', I18n.t('app.menu.login')
        assert_select 'li', I18n.t('app.menu.browse_breads')
      end
    end
  end

  test '#home - it contains gift section' do
    assert_select 'div.giftBreaded' do
      assert_select 'h1', I18n.t('app.gift.label')
      assert_select 'p', I18n.t('app.gift.description')
      assert_select 'a', html: I18n.t('app.gift.button_html')
    end
  end

  test '#home - it contains footer' do
    assert_select 'footer' do
      assert_select 'div' do
        assert_select 'ul' do
          assert_select 'li.footerLogo'
          assert_select 'ul.footer-links' do
            assert_select 'li', I18n.t('app.menu.browse_breads')
            assert_select 'li', I18n.t('app.menu.about')
            assert_select 'li', I18n.t('app.menu.apply_to_be_baker')
            assert_select 'li', I18n.t('app.footer.contact_us')
            assert_select 'li', I18n.t('app.footer.faq')
            assert_select 'li', I18n.t('app.footer.privacy_and_terms')
          end
        end
      end
      assert_select 'div' do
        assert_select 'p', I18n.t('app.footer.all_rights_reserved', current_year: Time.current.year)
      end
    end
  end

  test '#home - it contains initial part' do
    assert_select 'div' do
      assert_select 'span.content_Text' do
        assert_select 'section' do
          assert_select 'span', CGI.unescapeHTML(strip_tags(I18n.t('app.homepage.introduction_html')))
          assert_select 'p', strip_tags(I18n.t('app.homepage.description_html',
                                               number_breads: Rails.application.config.options[:default_number_of_breads]))
          assert_select 'a', html: I18n.t('app.homepage.breaded_button_html')
        end
      end
      assert_select 'div.mainBannerImg' do
        assert_select 'span.imgSection' do
          assert_select 'img.img-responsive'
        end
      end
    end
  end

  test '#home - it contains steps part' do
    assert_select 'div.pickupDeliveryStep' do
      assert_select 'section' do
        assert_select 'i', '1'
        assert_select 'h2.bigview', strip_tags(I18n.t('app.homepage.steps.first.title_big_html'))
        assert_select 'h2.mobview', I18n.t('app.homepage.steps.first.title_mob')
        assert_select 'p', I18n.t('app.homepage.steps.first.description')
      end
      assert_select 'section' do
        assert_select 'i', '2'
        assert_select 'h2.bigview', strip_tags(I18n.t('app.homepage.steps.second.title_big_html'))
        assert_select 'h2.mobview', I18n.t('app.homepage.steps.second.title_mob')
        assert_select 'p', I18n.t('app.homepage.steps.second.description')
      end
      assert_select 'section' do
        assert_select 'i', '3'
        assert_select 'h2.bigview', strip_tags(I18n.t('app.homepage.steps.third.title_big_html'))
        assert_select 'h2.mobview', I18n.t('app.homepage.steps.third.title_mob')
        assert_select 'p', I18n.t('app.homepage.steps.third.description')
      end
    end
  end

  test '#home - it contains reason to choose part' do
    assert_select 'span.imageText-1' do
      assert_select 'h4', I18n.t('app.homepage.featured.first.title')
      assert_select 'p', I18n.t('app.homepage.featured.first.description')
      assert_select 'a', I18n.t('app.homepage.featured.read_more_link')
    end
    assert_select 'div.seasonSection' do
      assert_select 'section' do
        assert_select 'h3.bigview', strip_tags(I18n.t('app.homepage.reasons_to_choose.title_big_html'))
        assert_select 'h3.mobview', strip_tags(I18n.t('app.homepage.reasons_to_choose.title_mob'))
        assert_select 'div:nth-of-type(1)' do
          assert_select 'h4', Regexp.new(I18n.t('app.homepage.reasons_to_choose.first.subtitle'))
          assert_select 'p', I18n.t('app.homepage.reasons_to_choose.first.description')
        end
        assert_select 'div:nth-of-type(2)' do
          assert_select 'h4', Regexp.new(I18n.t('app.homepage.reasons_to_choose.second.subtitle'))
          assert_select 'p', I18n.t('app.homepage.reasons_to_choose.second.description')
        end
        assert_select 'div:nth-of-type(3)' do
          assert_select 'h4', Regexp.new(I18n.t('app.homepage.reasons_to_choose.third.subtitle'))
          assert_select 'p', I18n.t('app.homepage.reasons_to_choose.third.description')
        end
      end
    end
  end

  test '#home - it contains breaded geniuses part' do
    assert_select 'span.imageText-2' do
      assert_select 'h4', I18n.t('app.homepage.featured.second.title')
      assert_select 'p', I18n.t('app.homepage.featured.second.description')
      assert_select 'a', I18n.t('app.homepage.featured.read_more_link')
    end
    assert_select 'div.bakers' do
      assert_select 'h3', I18n.t('app.homepage.breaded_geniuses.title')
      assert_select 'div:nth-of-type(1)' do
        assert_select 'p', I18n.t('app.homepage.breaded_geniuses.description')
      end
      assert_select 'div:nth-of-type(2)' do
        assert_select 'h4', I18n.t('app.homepage.breaded_geniuses.subsections.first.header')
        assert_select 'p', I18n.t('app.homepage.breaded_geniuses.subsections.first.description')
        assert_select 'a', I18n.t('app.homepage.breaded_geniuses.subsections.first.link')
      end
      assert_select 'div:nth-of-type(3)' do
        assert_select 'h4', I18n.t('app.homepage.breaded_geniuses.subsections.second.header')
        assert_select 'p', I18n.t('app.homepage.breaded_geniuses.subsections.second.description')
        assert_select 'a', I18n.t('app.homepage.breaded_geniuses.subsections.second.link')
      end
    end
  end

  test '#home - it contains plans part' do
    assert_select 'div.breadedPlan' do
      assert_select 'span.breadedPlanTitle', I18n.t('app.homepage.plans.title')
      assert_select 'section' do
        assert_select 'div:nth-of-type(1)' do
          assert_select 'h3', strip_tags(I18n.t('app.homepage.plans.first.header_html'))
          assert_select 'p', I18n.t('app.homepage.plans.first.description')
          assert_select 'span', I18n.t('app.homepage.plans.first.specification')
        end
        assert_select 'div:nth-of-type(2)' do
          assert_select 'h3', strip_tags(I18n.t('app.homepage.plans.second.header_html'))
          assert_select 'p', I18n.t('app.homepage.plans.second.description')
          assert_select 'span', I18n.t('app.homepage.plans.second.specification')
        end
        assert_select 'div:nth-of-type(3)' do
          assert_select 'h3', strip_tags(I18n.t('app.homepage.plans.third.header_html'))
          assert_select 'p', I18n.t('app.homepage.plans.third.description')
          assert_select 'span', I18n.t('app.homepage.plans.third.specification')
        end
      end
      assert_select 'a', I18n.t('app.homepage.breaded_button_simple')
    end
  end
end
