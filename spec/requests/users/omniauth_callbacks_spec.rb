# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'OmniauthCallbacks' do
  before { OmniAuth.config.test_mode = true }

  describe 'POST /auth/github/callback' do
    subject(:omniauth_callback) { post '/auth/github/callback' }

    before do
      OmniAuth.config.add_mock(:github,
                               provider: 'github',
                               uid: '12345678',
                               info: { nickname: 'wordi',
                                       email: 'hello@email.com',
                                       name: 'John Dou',
                                       image: '<image_link>' },
                               credentials: { token: '12345678' })
    end

    context 'when user already exists in the database with connected GitHub account' do
      let(:user) { create(:user, github_uid: '12345678', email: 'wordi@email.com') }

      before { user }

      it 'does not create new user' do
        expect { omniauth_callback }.not_to change(User, :count)
      end

      it 'logs in new user' do
        omniauth_callback
        expect(controller.current_user).to eq(user)
      end

      it 'creates a flash message' do
        omniauth_callback
        expect(flash[:notice]).to eq(I18n.t('devise.omniauth_callbacks.success', kind: 'GitHub'))
      end

      it 'redirects to the user profile page' do
        omniauth_callback
        expect(response).to redirect_to(user_path(user.id))
      end

      it 'returns http found status' do
        omniauth_callback
        expect(response).to have_http_status(:found)
      end
    end

    context 'when user with the same email already exists in the database' do
      let(:user) { create(:user, github_uid: nil, email: 'hello@email.com') }

      before { user }

      it 'does not create new user' do
        expect { omniauth_callback }.not_to change(User, :count)
      end

      it 'logs in new user' do
        omniauth_callback
        expect(controller.current_user).to eq(user)
      end

      it 'creates a flash message' do
        omniauth_callback
        expect(flash[:notice]).to eq(I18n.t('devise.omniauth_callbacks.success', kind: 'GitHub'))
      end

      it 'redirects to the user profile page' do
        omniauth_callback
        expect(response).to redirect_to(user_path(user.id))
      end

      it 'returns http found status' do
        omniauth_callback
        expect(response).to have_http_status(:found)
      end
    end

    context 'when it is a completely new user' do
      let(:expected_user_attributes) do
        {
          'github_uid' => '12345678',
          'email' => 'hello@email.com',
          'username' => 'wordi',
          'name' => 'John Dou'
        }
      end

      it 'creates new user' do
        expect { omniauth_callback }.to change(User, :count).by(1)
      end

      it 'creates user with necessary attributes' do
        omniauth_callback
        expect(User.last.attributes).to include(expected_user_attributes)
      end

      it 'creates confirmed user' do
        omniauth_callback
        expect(User.last).to be_confirmed
      end

      it 'logs in new user' do
        omniauth_callback
        expect(controller.current_user.github_uid).to eq('12345678')
      end

      it 'creates a flash message' do
        omniauth_callback
        expect(flash[:notice]).to eq(I18n.t('devise.omniauth_callbacks.success', kind: 'GitHub'))
      end

      it 'redirects to the user profile page' do
        omniauth_callback
        expect(response).to redirect_to(user_path(User.last.id))
      end

      it 'returns http found status' do
        omniauth_callback
        expect(response).to have_http_status(:found)
      end
    end

    context 'when it is a new user but omniauth hash is invalid' do
      before do
        OmniAuth.config.add_mock(:github,
                                 provider: 'github',
                                 uid: '12345678',
                                 info: { nickname: 'A',
                                         email: 'hello@email.com',
                                         name: 'John Dou',
                                         image: '<image_link>' },
                                 credentials: { token: '12345678' })
      end

      it 'does not create new user' do
        expect { omniauth_callback }.not_to change(User, :count)
      end

      it 'does not log in new user' do
        omniauth_callback
        expect(controller.current_user).to be_nil
      end

      it 'creates a flash message' do
        omniauth_callback
        expect(flash[:alert])
          .to eq(I18n.t('devise.omniauth_callbacks.failure_creating', kind: 'GitHub'))
      end

      it 'redirects to the login page' do
        omniauth_callback
        expect(response).to redirect_to(new_user_session_path)
      end

      it 'returns http found status' do
        omniauth_callback
        expect(response).to have_http_status(:found)
      end
    end
  end

  describe 'POST /auth/google_oauth2/callback' do
    subject(:omniauth_callback) { post '/auth/google_oauth2/callback' }

    before do
      OmniAuth.config.add_mock(:google_oauth2,
                               provider: 'google_oauth2',
                               uid: '123456789012345678901',
                               info: { email: 'hello@gmail.com',
                                       name: 'John Dou',
                                       image: '<image_link>' },
                               credentials: { token: '12345678' })
    end

    context 'when user already exists in the database with connected Google account' do
      let(:user) { create(:user, google_uid: '123456789012345678901', email: 'wordi@gmail.com') }

      before { user }

      it 'does not create new user' do
        expect { omniauth_callback }.not_to change(User, :count)
      end

      it 'logs in new user' do
        omniauth_callback
        expect(controller.current_user).to eq(user)
      end

      it 'creates a flash message' do
        omniauth_callback
        expect(flash[:notice]).to eq(I18n.t('devise.omniauth_callbacks.success', kind: 'Google'))
      end

      it 'redirects to the user profile page' do
        omniauth_callback
        expect(response).to redirect_to(user_path(user.id))
      end

      it 'returns http found status' do
        omniauth_callback
        expect(response).to have_http_status(:found)
      end
    end

    context 'when user already exists in the database' do
      let(:user) { create(:user, google_uid: nil, email: 'hello@gmail.com') }

      before { user }

      it 'does not create new user' do
        expect { omniauth_callback }.not_to change(User, :count)
      end

      it 'logs in new user' do
        omniauth_callback
        expect(controller.current_user).to eq(user)
      end

      it 'creates a flash message' do
        omniauth_callback
        expect(flash[:notice]).to eq(I18n.t('devise.omniauth_callbacks.success', kind: 'Google'))
      end

      it 'redirects to the user profile page' do
        omniauth_callback
        expect(response).to redirect_to(user_path(user.id))
      end

      it 'returns http found status' do
        omniauth_callback
        expect(response).to have_http_status(:found)
      end
    end

    context 'when it is a completely new user' do
      let(:expected_user_attributes) do
        {
          'google_uid' => '123456789012345678901',
          'email' => 'hello@gmail.com',
          'username' => 'hello',
          'name' => 'John Dou'
        }
      end

      it 'creates new user' do
        expect { omniauth_callback }.to change(User, :count).by(1)
      end

      it 'creates user with necessary attributes' do
        omniauth_callback
        expect(User.last.attributes).to include(expected_user_attributes)
      end

      it 'creates confirmed user' do
        omniauth_callback
        expect(User.last).to be_confirmed
      end

      it 'logs in new user' do
        omniauth_callback
        expect(controller.current_user.google_uid).to eq('123456789012345678901')
      end

      it 'creates a flash message' do
        omniauth_callback
        expect(flash[:notice]).to eq(I18n.t('devise.omniauth_callbacks.success', kind: 'Google'))
      end

      it 'redirects to the user profile page' do
        omniauth_callback
        expect(response).to redirect_to(user_path(User.last.id))
      end

      it 'returns http found status' do
        omniauth_callback
        expect(response).to have_http_status(:found)
      end
    end

    context 'when it is a new user but omniauth hash is invalid' do
      before do
        OmniAuth.config.add_mock(:google_oauth2,
                                 provider: 'google_oauth2',
                                 uid: '123456789012345678901',
                                 info: { email: 'hello',
                                         name: 'John Dou',
                                         image: '<image_link>' },
                                 credentials: { token: '12345678' })
      end

      it 'does not create new user' do
        expect { omniauth_callback }.not_to change(User, :count)
      end

      it 'does not log in new user' do
        omniauth_callback
        expect(controller.current_user).to be_nil
      end

      it 'creates a flash message' do
        omniauth_callback
        expect(flash[:alert])
          .to eq(I18n.t('devise.omniauth_callbacks.failure_creating', kind: 'Google'))
      end

      it 'redirects to the login page' do
        omniauth_callback
        expect(response).to redirect_to(new_user_session_path)
      end

      it 'returns http found status' do
        omniauth_callback
        expect(response).to have_http_status(:found)
      end
    end
  end
end
