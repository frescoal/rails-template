class CustomDeviseMailer < Devise::Mailer

  helper :application # gives access to all helpers defined within `application_helper`.
  include Devise::Controllers::UrlHelpers # Optional. eg. `confirmation_url`
  default template_path: 'devise/mailer' # to make sure that your mailer uses the devise views

  def confirmation_instructions(record, token, opts={})
    attachments.inline['logo.png'] = File.read("#{Rails.root}/app/assets/images/logo.png")
    @token = token
    devise_mail(record, :confirmation_instructions, opts)
  end

  def reset_password_instructions(record, token, opts={})
    attachments.inline['logo.png'] = File.read("#{Rails.root}/app/assets/images/logo.png")
    @token = token
    devise_mail(record, :reset_password_instructions, opts)
  end

  def unlock_instructions(record, token, opts={})
    attachments.inline['logo.png'] = File.read("#{Rails.root}/app/assets/images/logo.png")
    @token = token
    devise_mail(record, :unlock_instructions, opts)
  end

  def email_changed(record, opts={})
    attachments.inline['logo.png'] = File.read("#{Rails.root}/app/assets/images/logo.png")
    devise_mail(record, :email_changed, opts)
  end

  def password_change(record, opts={})
    raise
    attachments.inline['logo.png'] = File.read("#{Rails.root}/app/assets/images/logo.png")
    devise_mail(record, :password_change, opts)
  end

end
