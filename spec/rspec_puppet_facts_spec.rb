require 'spec_helper'

fixtures = {
  :metadata_missing_os_support =>
    File.read('spec/fixtures/metadata.json_with_missing_operatingsystem_support'),
  :metadata_valid =>
    JSON.parse(File.read('spec/fixtures/metadata.json'),
               {:symbolize_names => true}),
}


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
              expect(File).to receive(:file?).with('metadata.json').and_return true
              expect(File).to receive(:read).with('metadata.json').and_return fixtures[:metadata_missing_os_support]
            end

            it { expect { subject }.to raise_error(StandardError, /Unknown operatingsystem support/) }
          end
        end

        context 'With a valid metadata.json' do
          before :each do
            expect(RspecPuppetFacts).to receive(:meta_supported_os).and_return(fixtures[:metadata_valid][:operatingsystem_support])
          end

          it 'should return a hash' do
            expect(subject.class).to eq Hash
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
    end

    context 'When specifying supported_os with string hash keys' do
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

    context 'When specifying supported_os with symbol hash keys' do
      subject {
        on_supported_os(
          {
            :supported_os => [
              {
                :operatingsystem => "Debian",
                :operatingsystemrelease => [
                  "6",
                  "7"
                ]
              },
              {
                :operatingsystem => "RedHat",
                :operatingsystemrelease => [
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

    context 'When testing OpenBSD 5.7' do
      subject {
        on_supported_os(
          {
            :supported_os => [
              {
                "operatingsystem" => "OpenBSD",
                "operatingsystemrelease" => [
                  "5.7",
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
          'openbsd-5-amd64',
        ]
      end
    end

    unless Facter.version.to_f < 2.4
      context 'When testing Windows 7' do
        subject {
          on_supported_os(
            {
              :supported_os => [
                {
                  "operatingsystem" => "windows",
                  "operatingsystemrelease" => [
                    "7",
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
            'windows-7-x64',
          ]
        end
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

  describe '#get_metadata' do
    subject { RspecPuppetFacts.get_metadata() }

    context 'with missing metadata.json' do
      before :each do
        expect(File).to receive(:file?).with('metadata.json').and_return false
      end
      it { expect { subject }.to raise_error(StandardError, /Can't find metadata.json/) }
    end

    context 'with metadata.json present' do
      before :each do
        expect(File).to receive(:file?).with('metadata.json').and_return true
        expect(File).to receive(:read).with('metadata.json').and_return "guard_str"
        expect(JSON).to receive(:parse).with("guard_str", {:symbolize_names => true}).and_return "ok"
      end
      it { is_expected.to eq("ok") }
    end

  end

  describe '#get_meta_supported_os' do
    subject { RspecPuppetFacts.get_meta_supported_os() }

    context 'with valid operatingsystem_support section' do
      before :each do
        expect(RspecPuppetFacts).to receive(:get_metadata).and_return(fixtures[:metadata_valid])
      end
      it { is_expected.to eq fixtures[:metadata_valid][:operatingsystem_support] }
    end

    context 'with missing operatingsystem_support section' do
      before :each do
        expect(RspecPuppetFacts).to receive(:get_metadata).and_return(JSON.parse(fixtures[:metadata_missing_os_support]))
      end
      it { expect{subject}.to raise_error(StandardError, /Unknown operatingsystem support/) }
    end
  end

end
