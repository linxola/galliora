# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Landing page' do
  before { visit root_path }

  it 'shows welcoming text to the user' do
    expect(page).to have_content('Welcome to Galliora!')
  end

  it 'shows link-button that redirects user to home page or login/register screen' do
    click_link 'Explore'

    expect(page).to have_current_path(new_user_registration_url)
  end

  it 'shows a link to an author of a background image' do
    expect(page).to have_link('Andy Bay from Pixabay', href: 'https://pixabay.com/users/andy_bay-1006510/')
  end
end
