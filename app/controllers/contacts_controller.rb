# frozen_string_literal: true

class ContactsController < ApplicationController
  skip_before_action :authenticate_user!, only: %i[new create]

  def new; end

  def create
    # TODO: what to do with message (send over email, store at db, etc.)?
    redirect_to new_contact_path, notice: I18n.t('app.contacts.new.notification')
  end

  def support; end

  def send_support_message
    # TODO: what to do with message (send over email, store at db, etc.)?
    redirect_to support_contacts_path, notice: I18n.t('app.contacts.send_support_message.notification')
  end
end
