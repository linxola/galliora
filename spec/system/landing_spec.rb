# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Landing page' do
  before { visit root_path }

  it 'shows welcoming text to the user' do
    expect(page).to have_content('Welcome to Galliora!')
  end

  it 'shows link-button that redirects user to home page or login/register screen' do
    click_link 'Explore'

    expect(page).to have_current_path('/')
  end

  it 'shows a link to an author of a background image' do
    expect(page).to have_link('Yves from Pixabay', href: 'https://pixabay.com/users/ykaiavu-7068951/')
  end
end
