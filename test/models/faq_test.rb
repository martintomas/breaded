# frozen_string_literal: true

require 'test_helper'

class FaqTest < ActiveSupport::TestCase
  setup do
    @full_content = { question: localised_texts(:how_many_breads_question),
                      answer: localised_texts(:how_many_breads_answer) }
    @faq = faqs(:faq_1)
  end

  test 'the validity - empty is not valid' do
    model = Faq.new
    refute model.valid?
  end

  test 'the validity - with all is valid' do
    model = Faq.new @full_content
    assert model.valid?, model.errors.full_messages
  end

  test 'the validity - without question is not valid' do
    invalid_with_missing Faq, :question
  end

  test 'the validity - without answer is not valid' do
    invalid_with_missing Faq, :answer
  end

  test '#to_s' do
    assert_equal @faq.localized_question, @faq.to_s
  end
end
