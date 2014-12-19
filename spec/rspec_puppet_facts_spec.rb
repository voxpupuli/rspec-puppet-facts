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

    context 'When specifying supported_os' do
      let(:os_sup) do
        on_supported_os(
          {
            :supported_os => [
              {
                "operatingsystem" => "Debian",
                "operatingsystemrelease" => [
                  "6",
                  "7"
                ]
              },
              {
                "operatingsystem" => "RedHat",
                "operatingsystemrelease" => [
                  "5",
                  "6"
                ]
              }
            ]
          }
        )
      end
      it 'should return a hash' do
        expect(os_sup.class).to eq Hash
      end
    end
  end
end
