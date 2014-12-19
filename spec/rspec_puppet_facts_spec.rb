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
      subject {
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
      }
      it 'should return a hash' do
        expect(subject.class).to eq Hash
      end
      it 'should have 4 elements' do
        expect(subject.size).to eq 4
      end
    end
  end
end
