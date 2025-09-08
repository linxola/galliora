# frozen_string_literal: true

module ApplicationHelper
  def page_title(title)
    [title.presence, 'Galliora'].compact.join(' | ')
  end
end
