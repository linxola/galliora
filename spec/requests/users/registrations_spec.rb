# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Registrations' do
  describe 'POST /' do
    subject(:register) do
      post '/', params: { user: user_params }
    end

    context 'with valid parameters' do
      let(:user_params) { { username: 'test', email: 'sms@test.io', password: 'testtesttest' } }

      it 'allows to create user with username, email and password' do
        expect { register }.to change(User, :count).by(1)
      end

      it 'clears created by devise flash messages' do
        register
        expect(flash).to be_empty
      end

      it 'redirects to email confirmation screen' do
        register
        expect(response).to redirect_to(new_user_confirmation_path)
      end

      it 'returns http see_other status' do
        register
        expect(response).to have_http_status(:see_other)
      end
    end

    context 'with invalid parameters' do
      let(:user_params) { { username: 'test!@#', email: 'sms@test.io', password: 'testtesttest' } }

      it 'allows to create user with username, email and password' do
        expect { register }.not_to change(User, :count)
      end

      it 'clears created by devise flash messages' do
        register
        expect(flash).to be_empty
      end

      it 'does not redirect' do
        register
        expect(response).not_to redirect_to(new_user_confirmation_path)
      end

      it 'returns http unprocessable_entity status' do
        register
        expect(response).to have_http_status(:unprocessable_entity)
      end
    end

    context 'when recaptcha fails' do
      let(:user_params) { { username: 'test', email: 'sms@test.io', password: 'testtesttest' } }

      before { Recaptcha.configuration.skip_verify_env.delete('test') }
      after { Recaptcha.configuration.skip_verify_env.append('test') }

      context 'when only recaptcha v3 fails' do
        before do
          # rubocop:disable RSpec/AnyInstance
          allow_any_instance_of(Users::RegistrationsController).to receive(:verify_recaptcha)
            .and_return(true)
          allow_any_instance_of(Users::RegistrationsController).to receive(:verify_recaptcha)
            .with(action: 'login', minimum_score: 0.5,
                  secret_key: ENV.fetch('RECAPTCHA_SECRET_KEY_V3'))
            .and_return(false)
          # rubocop:enable RSpec/AnyInstance
          register
        end

        it 'triggers recaptcha v2 and logs in without errors' do
          expect(flash[:recaptcha_error]).to be_nil
        end
      end

      context 'when v3 and v2 recaptchas fail' do
        before { register }

        it 'adds flash error' do
          expect(flash[:recaptcha_error]).to be_present
        end

        it 'returns http unprocessable_entity status' do
          expect(response).to have_http_status(:unprocessable_entity)
        end
      end
    end
  end
end
