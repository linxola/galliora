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

      before { post_log_in }

      it 'redirects to the user profile page' do
        expect(response).to redirect_to(user_path(user.id))
      end

      it 'returns http see_other status' do
        expect(response).to have_http_status(:see_other)
      end
    end

    context 'when email as login' do
      let(:login_params) { { login: 'sms@test.io', password: 'TestPassword' } }

      before { post_log_in }

      it 'redirects to the user profile page' do
        expect(response).to redirect_to(user_path(user.id))
      end

      it 'returns http see_other status' do
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
        expect(flash[:alert]).to eq(I18n.t('devise.failure.inactive'))
      end

      it 'redirects to the email confirmation page' do
        post_log_in
        expect(response).to redirect_to(new_user_confirmation_path)
      end

      it 'returns http found status' do
        post_log_in
        expect(response).to have_http_status(:found)
      end
    end

    context 'when invalid login/password' do
      let(:login_params) { { login: '', password: '' } }

      before { post_log_in }

      it 'creates alert flash message' do
        expect(flash[:alert]).to eq(I18n.t('devise.failure.invalid'))
      end

      it 'does not redirect to root path' do
        expect(response).not_to redirect_to(root_path)
      end

      it 'returns http unprocessable_entity status' do
        expect(response).to have_http_status(:unprocessable_entity)
      end
    end

    context 'when recaptcha fails' do
      let(:login_params) { { login: 'test', password: 'TestPassword' } }

      before { Recaptcha.configuration.skip_verify_env.delete('test') }
      after { Recaptcha.configuration.skip_verify_env.append('test') }

      context 'when only recaptcha v3 fails' do
        before do
          # rubocop:disable RSpec/AnyInstance
          allow_any_instance_of(Users::SessionsController).to receive(:verify_recaptcha)
            .and_return(true)
          allow_any_instance_of(Users::SessionsController).to receive(:verify_recaptcha)
            .with(action: 'login', minimum_score: 0.5,
                  secret_key: ENV.fetch('RECAPTCHA_SECRET_KEY_V3'))
            .and_return(false)
          # rubocop:enable RSpec/AnyInstance
          post_log_in
        end

        it 'triggers recaptcha v2 and logs in without errors' do
          expect(flash[:recaptcha_error]).to be_nil
        end
      end

      context 'when v3 and v2 recaptchas fail' do
        before { post_log_in }

        it 'adds flash error' do
          expect(flash[:recaptcha_error]).to be_present
        end

        it 'returns http unprocessable_entity status' do
          expect(response).to have_http_status(:unprocessable_entity)
        end
      end
    end
  end

  describe 'DELETE /sign_out' do
    subject(:delete_log_out) do
      delete '/sign_out'
    end

    let(:user) { create(:user, email: 'sms@test.io', username: 'test', password: 'TestPassword') }

    before do
      sign_in(user)
      delete_log_out
    end

    it 'redirects to login page' do
      expect(response).to redirect_to(new_user_session_path)
    end

    it 'returns http see_other status' do
      expect(response).to have_http_status(:see_other)
    end
  end
end
