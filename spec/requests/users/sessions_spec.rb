# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Sessions' do
  describe 'POST /sign_in' do
    subject(:post_log_in) do
      post '/sign_in', params: { user: login_params }
    end

    let(:user) { create(:user, email: 'sms@test.io', username: 'test', password: 'TestPassword') }

    before { user }

    context 'when username as login' do
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

    context 'when email as login' do
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

    context 'when user is unconfirmed' do
      let(:new_user) do
        create(:user, email: 'test@confirm.me', username: 'confirm_me', password: 'TestPassword',
                      confirmed_at: nil)
      end
      let(:login_params) { { login: 'confirm_me', password: 'TestPassword' } }

      before { new_user }

      it 'sends confirmation email to the user' do
        expect { post_log_in }.to change(ActionMailer::Base.deliveries, :size).by(1)
      end

      it 'creates alert flash message' do
        post_log_in
        expect(flash[:alert]).to eq(I18n.t('user.flashes.confirmation_needed_before_login'))
      end

      it 'redirects to the email confirmation page' do
        post_log_in
        expect(response).to redirect_to(new_user_confirmation_path)
      end
    end
  end
end
