# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ApplicationHelper do
  describe '#page_title' do
    context 'when the title is nil' do
      let(:title) { nil }

      it 'shows just Galliora in the title' do
        expect(helper.page_title(title))
          .to eq('Galliora')
      end
    end

    context 'when there is something in the title' do
      let(:title) { 'Hello World!' }

      it "shows text from title and '| Galliora' in the end" do
        expect(helper.page_title(title))
          .to eq("#{title} | Galliora")
      end
    end
  end
end
