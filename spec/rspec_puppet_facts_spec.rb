require 'spec_helper'

describe 'RspecPuppetFacts' do

  describe '#on_supported_os' do

    context 'Without parameter' do
      subject { on_supported_os() }

      context 'Without metadata.json' do
        it 'should fail' do
          pending "I Have No Idea What I'm Doing with stubbing..."
          expect { subject }.to raise_error(StandardError, /Can't find metadata.json/)
        end
      end

      context 'With a metadata.json' do
        fixture = File.read('spec/fixtures/metadata.json')
        File.stubs('file?')
        File.stubs('read')
        File.expects('file?').with('metadata.json').returns true
        File.expects('read').with('metadata.json').returns fixture
        it 'should return a hash' do
          expect( on_supported_os().class ).to eq Hash
        end
        it 'should have 5 elements' do
          expect(subject.size).to eq 5
        end
        it 'should return supported OS' do
          expect(subject.keys.sort).to eq [
            'debian-6-x86_64',
            'debian-7-x86_64',
            'redhat-5-x86_64',
            'redhat-6-x86_64',
            'redhat-7-x86_64',
          ]
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
      it 'should return supported OS' do
        expect(subject.keys.sort).to eq [
          'debian-6-x86_64',
          'debian-7-x86_64',
          'redhat-5-x86_64',
          'redhat-6-x86_64',
        ]
      end
    end

    context 'When operatingsystemrelease has space' do
      subject {
        on_supported_os(
          {
            :supported_os => [
              {
                "operatingsystem" => "SLES",
                "operatingsystemrelease" => [
                  "11 SP1"
                ]
              }
            ]
          }
        )
      }
      it 'should return a hash' do
        expect(subject.class).to eq Hash
      end
      it 'should have 1 elements' do
        expect(subject.size).to eq 1
      end
      it 'should return supported OS' do
        expect(subject.keys.sort).to eq [
          'sles-11-x86_64',
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
        pending "How to catch warn?"
        expect(subject).should_receive(:warn).with(/Can't find facts for 'debian-4-x86_64'/)
      end
    end
  end
end
