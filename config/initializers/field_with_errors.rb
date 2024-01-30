# frozen_string_literal: true

ActionView::Base.field_error_proc = proc do |html_tag|
  html_tag.gsub(/class="(.*?)"/, 'class="\1 is-invalid"').html_safe
end
