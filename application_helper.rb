module ApplicationHelper
  def flash_class(level)
    case level
    when 'notice' then
      'info'
    when 'success' then
      'success'
    when 'error' then
      'danger'
    when 'alert' then
      'danger'
    else
      'primary'
    end
  end

  def time_format(date)
    date.strftime('%H:%M') if date.present?
  end

  def date_format(date)
    date.strftime('%d.%m.%Y') if date.present?
  end

  def datetime_format(date)
    date.strftime('%d.%m.%Y à %H:%M') if date.present?
  end
end
