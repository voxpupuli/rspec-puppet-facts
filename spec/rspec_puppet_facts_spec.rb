require 'spec_helper'

describe 'RspecPuppetFacts' do
  describe '#on_supported_os' do
    context 'Without parameter' do
      context 'Without metadata.json' do
        it 'should fail' do
          expect { on_supported_os() }.to raise_error(StandardError)
        end
      end
    end
  end
end
