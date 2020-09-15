# frozen_string_literal: true

class TestMailer < ApplicationMailer
  def test
    mail(from: 'martintomas@seznam.cz', to: 'martintomas@seznam.cz', subject: 'test')
  end

  def raise_exception
    raise StandardError, 'background job exception'
  end
end
