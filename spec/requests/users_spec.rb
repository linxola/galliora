# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Users' do
  describe 'GET /users/:id' do
    subject(:show_user) do
      get "/users/#{user.id}"
    end

    let(:user) { create(:user, email: 'sms@test.io', username: 'test', password: 'TestPassword') }

    before do
      sign_in(user)
      show_user
    end

    it 'returns http ok status' do
      expect(response).to have_http_status(:ok)
    end
  end
end
