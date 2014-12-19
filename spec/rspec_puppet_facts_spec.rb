require 'spec_helper'

describe 'RspecPuppetFacts' do

  describe '#on_supported_os' do

    context 'Without parameter' do
      subject { on_supported_os() }

      context 'Without metadata.json' do
        it 'should fail' do
          expect { subject }.to raise_error(StandardError)
        end
      end

      context 'With a metadata.json' do
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
      it 'should return supported OS' do
        expect(subject.keys).to eq [
          'debian-6-x86_64',
          'debian-7-x86_64',
          'redhat-5-x86_64',
          'redhat-6-x86_64',
        ]
      end
    end

    context 'When specifying wrong supported_os' do
      subject {
        on_supported_os(
          {
            :supported_os => [
              {
                "operatingsystem" => "Debian",
                "operatingsystemrelease" => [
                  "4",
                ],
              },
            ]
          }
        )
      }

      it 'should fail' do
        expect { subject }.to raise_error(StandardError, /Can't find facts for 'debian-4-x86_64'/)
      end
    end
  end
end
