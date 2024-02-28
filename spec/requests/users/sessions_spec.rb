# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Sessions' do
  describe 'POST /sign_in' do
    subject(:post_log_in) do
      post '/sign_in', params: { user: login_params }
    end

    let(:user) { create(:user, email: 'sms@test.io', username: 'test', password: 'TestPassword') }

    before { user }

    context 'with username' do
      let(:login_params) { { login: 'test', password: 'TestPassword' } }

      it 'redirects to root path' do
        post_log_in
        expect(response).to redirect_to(root_path)
      end

      it 'returns http see_other status' do
        post_log_in
        expect(response).to have_http_status(:see_other)
      end
    end

    context 'with email' do
      let(:login_params) { { login: 'sms@test.io', password: 'TestPassword' } }

      it 'redirects to root path' do
        post_log_in
        expect(response).to redirect_to(root_path)
      end

      it 'returns http see_other status' do
        post_log_in
        expect(response).to have_http_status(:see_other)
      end
    end
  end
end
