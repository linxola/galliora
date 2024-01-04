# frozen_string_literal: true

require 'rails_helper'

RSpec.describe User do
  describe 'Validations' do
    it { is_expected.to validate_presence_of(:username) }

    it { is_expected.to validate_uniqueness_of(:username) }

    # Testing format's validation of username field
    it { is_expected.to allow_value('_User.Name-99_').for(:username) }
    it { is_expected.not_to allow_value('a').for(:username) }
    it { is_expected.not_to allow_value('abc$%^&*').for(:username) }
    it { is_expected.not_to allow_value('a' * 33).for(:username) }

    it { is_expected.to validate_length_of(:name).is_at_most(64).allow_nil }
    it { is_expected.to validate_length_of(:about).is_at_most(256).allow_nil }
  end
end
