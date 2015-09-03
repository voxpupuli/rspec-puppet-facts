require 'spec_helper'

describe 'RspecPuppetFacts' do

  describe '#on_supported_os' do

    context 'Without parameter' do
      subject { on_supported_os() }

      context 'Without metadata.json' do
        it { expect { subject }.to raise_error(StandardError, /Can't find metadata.json/) }
      end

      context 'With a metadata.json' do

        context 'With a broken metadata.json' do

          context 'With missing operatingsystem_support section' do
            before :each do
              fixture = File.read('spec/fixtures/metadata.json_with_missing_operatingsystem_support')
              expect(File).to receive(:file?).with('metadata.json').and_return true
              expect(File).to receive(:read).with('metadata.json').and_return fixture
            end

            it { expect { subject }.to raise_error(StandardError, /Unknown operatingsystem support/) }
          end
        end

        context 'With a valid metadata.json' do
          before :each do
            fixture = File.read('spec/fixtures/metadata.json')
            expect(File).to receive(:file?).with('metadata.json').and_return true
            expect(File).to receive(:read).and_call_original
            expect(File).to receive(:read).with('metadata.json').and_return fixture
          end

          it 'should return a hash' do
            pending 'FIXME'
            expect( on_supported_os().class ).to eq Hash
          end
          it 'should have 5 elements' do
            pending 'FIXME'
            expect(subject.size).to eq 5
          end
          it 'should return supported OS' do
            pending 'FIXME'
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

    context 'When testing FreeBSD 10' do
      subject {
        on_supported_os(
          {
            :supported_os => [
              {
                "operatingsystem" => "FreeBSD",
                "operatingsystemrelease" => [
                  "10",
                ],
              },
            ],
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
          'freebsd-10-amd64',
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

      it 'should output warning message' do
        pending "TODO: Show a warning when missing facts in database"
        expect { subject }.to output(/Can't find facts for 'debian-4-x86_64'/).to_stderr
      end
    end

    context 'When specifying rolling release operating system' do
      subject {
        on_supported_os(
          {
            :supported_os => [
              {
                "operatingsystem" => "Debian",
                "operatingsystemrelease" => [
                  "8",
                ],
              },
              {
                "operatingsystem" => "Archlinux",
              },
            ]
          }
        )
      }

      it 'should return a hash' do
        expect(subject.class).to eq Hash
      end
      it 'should have 2 elements' do
        expect(subject.size).to eq 2
      end
      it 'should return supported OS' do
        expect(subject.keys.sort).to eq [
          'archlinux-3-x86_64',
          'debian-8-x86_64',
        ]
      end
    end
  end
end
