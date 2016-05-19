require 'spec_helper'
require 'json'

describe RspecPuppetFacts do
  let(:metadata_file) do
    'spec/fixtures/metadata.json'
  end

  describe '#on_supported_os' do

    context 'Without specifying supported_os' do
      subject { on_supported_os }

      context 'Without metadata.json' do
        before(:each) do
          expect(File).to receive(:file?).with('metadata.json').and_return false
        end

        it { expect { subject }.to raise_error(StandardError, /Can't find metadata.json/) }
      end

      context 'With a metadata.json' do
        it 'can load the metadata file' do
          allow(RspecPuppetFacts).to receive(:metadata_file).and_return(metadata_file)
          RspecPuppetFacts.reset
          expect(RspecPuppetFacts.metadata).to be_a Hash
          expect(RspecPuppetFacts.metadata['name']).to eq 'mcanevet-mymodule'
        end

        context 'With a valid metadata.json' do
          let(:metadata) do
            fixture = File.read(metadata_file)
            JSON.parse fixture
          end

          before :each do
            allow(RspecPuppetFacts).to receive(:metadata).and_return(metadata)
          end

          it 'should return a hash' do
            is_expected.to be_a Hash
          end

          it 'should have 5 elements' do
            expect(subject.size).to eq 5
          end

          it 'should return supported OS' do
            expect(subject.keys.sort).to eq %w(
              debian-6-x86_64
              debian-7-x86_64
              redhat-5-x86_64
              redhat-6-x86_64
              redhat-7-x86_64
            )
          end

          it 'should be able to filter the received OS facts' do
            allow(RspecPuppetFacts).to receive(:spec_facts_os_filter).and_return('redhat')
            expect(subject.keys.sort).to eq %w(
              redhat-5-x86_64
              redhat-6-x86_64
              redhat-7-x86_64
            )
          end
        end

        context 'With a broken metadata.json' do
          before :each do
            allow(RspecPuppetFacts).to receive(:metadata).and_return(metadata)
          end

          context 'With a missing operatingsystem_support section' do
            let(:metadata) do
              {}
            end

            it { expect { subject }.to raise_error(StandardError, /Unknown operatingsystem support/) }
          end

          context 'With a wrong operatingsystem_support section' do
            let(:metadata) do
              {
                  'operatingsystem_support' => 'Ubuntu',
              }
            end

            it { expect { subject }.to raise_error(StandardError, /Unknown operatingsystem support/) }
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
        is_expected.to be_a Hash
      end

      it 'should have 4 elements' do
        expect(subject.size).to eq 4
      end

      it 'should return supported OS' do
        expect(subject.keys.sort).to eq %w(
          debian-6-x86_64
          debian-7-x86_64
          redhat-5-x86_64
          redhat-6-x86_64
        )
      end

      it 'should be able to filter the received OS facts' do
        allow(RspecPuppetFacts).to receive(:spec_facts_os_filter).and_return('redhat')
        expect(subject.keys.sort).to eq %w(
          redhat-5-x86_64
          redhat-6-x86_64
        )
      end
    end

    context 'When testing Ubuntu' do
      subject {
        on_supported_os(
          {
            :supported_os => [
              {
                "operatingsystem" => "Ubuntu",
                "operatingsystemrelease" => [
                  "14.04",
                  "14.10",
                  "15.04",
                  "15.10",
                  "16.04",
                ],
              },
            ],
          }
        )
      }
      it 'should return a hash' do
        expect(subject.class).to eq Hash
      end
      it 'should have 5 elements' do
        pending "There's obviously a bug here!"
        expect(subject.size).to eq 5
      end
      it 'should return supported OS' do
        pending "There's obviously a bug here!"
        expect(subject.keys.sort).to eq [
          'ubuntu-14.04-x86_64',
          'ubuntu-14.10-x86_64',
          'ubuntu-15.04-x86_64',
          'ubuntu-15.10-x86_64',
          'ubuntu-16.04-x86_64',
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

    context 'When testing Solaris 11', :if => Facter.version.to_f >= 2.0 do
      subject {
        on_supported_os(
            {
                :supported_os => [
                    {
                        "operatingsystem" => "Solaris",
                        "operatingsystemrelease" => [
                            "11",
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
        expect(subject.keys.sort).to eq %w(
          solaris-11-i86pc
        )
      end
    end

    context 'When testing Windows 7', :if => Facter.version.to_f >= 2.4 do
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
        expect(RspecPuppetFacts).to receive(:warning).with(/No facts were found in the FacterDB/)
        subject
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
        expect(subject.keys.sort).to eq %w(
          archlinux-3-x86_64
          debian-8-x86_64
        )
      end
    end
  end

  context '#misc' do
    it 'should have a common facts structure' do
      RspecPuppetFacts.reset
      expect(subject.common_facts).to be_a Hash
      expect(subject.common_facts).not_to be_empty
    end

    it 'should not add "augeasversion" if Augeas is supported' do
      allow(Puppet.features).to receive(:augeas?).and_return(false)
      RspecPuppetFacts.reset
      expect(subject.common_facts).not_to include :augeasversion
    end

    it 'should determine the Augeas version if Augeas is supported' do
      module Augeas_stub
        NO_MODL_AUTOLOAD = true
        def self.open(*_args)
          self
        end
        def self.get(*_args)
          'my_version'
        end
      end

      allow(Puppet.features).to receive(:augeas?).and_return(true)
      stub_const('Augeas', Augeas_stub)
      RspecPuppetFacts.reset
      expect(subject.common_facts[:augeasversion]).to eq 'my_version'
    end

    it 'can output a warning message' do
      expect { RspecPuppetFacts.warning('test') }.to output(/test/).to_stderr_from_any_process
    end
  end

end
