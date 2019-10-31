require 'spec_helper'
require 'json'

describe RspecPuppetFacts do
  let(:metadata_file) do
    'spec/fixtures/metadata.json'
  end

  describe '#on_supported_os' do
    context 'With RSpec.configuration.facterdb_string_keys' do
      subject(:result) do
        on_supported_os(
          {
            :supported_os => [
              {
                "operatingsystem"        => "Debian",
                "operatingsystemrelease" => ['7'],
              },
            ],
          }
        )
      end

      let(:get_keys) do
        proc { |r| r.keys + r.select { |_,v| v.is_a?(Hash) }.map { |_,v| get_keys.call(v) }.flatten }
      end

      context 'set to true' do
        before(:each) do
          RSpec.configuration.facterdb_string_keys = true
        end

        after(:each) do
          RSpec.configuration.facterdb_string_keys = false
        end

        it 'returns a fact set with all the keys as Strings' do
          expect(get_keys.call(result['debian-7-x86_64'])).to all(be_a(String))
        end
      end

      context 'set to false' do
        before(:each) do
          RSpec.configuration.facterdb_string_keys = false
        end

        it 'returns a fact set with all the keys as Symbols or Strings' do
          expect(get_keys.call(result['debian-7-x86_64'])).to all(be_a(Symbol).or(be_a(String)))
        end
      end
    end

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
              debian-7-x86_64
              debian-8-x86_64
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
                  "7",
                  "8",
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
          debian-7-x86_64
          debian-8-x86_64
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

    context 'When specifying a supported_os with a single release as a String' do
      subject(:factsets) do
        on_supported_os(
          {
            :supported_os => [
              { 'operatingsystem' => 'RedHat', 'operatingsystemrelease' => '7' },
            ]
          }
        )
      end

      it 'returns a Hash' do
        expect(factsets).to be_a(Hash)
      end

      it 'returns a single fact set' do
        expect(factsets.size).to eq(1)
      end

      it 'returns a fact set for the specified release' do
        expect(factsets).to include('redhat-7-x86_64' => include(:operatingsystemmajrelease => '7'))
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
                  "12.04",
                  "14.04",
                  "16.04",
                ],
              },
            ],
          }
        )
      }

      let(:expected_fact_sets) do
        ['ubuntu-12.04-x86_64', 'ubuntu-14.04-x86_64', 'ubuntu-16.04-x86_64']
      end

      it 'should return a hash' do
        expect(subject.class).to eq Hash
      end
      it 'should have 3 elements' do
        expect(subject.size).to eq(expected_fact_sets.size)
      end
      it 'should return supported OS' do
        expect(subject.keys.sort).to eq(expected_fact_sets)
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
            :facterversion => '2.4',
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

    context 'When testing OpenBSD' do
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
            :facterversion => '2.4',
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
          'openbsd-5.7-amd64',
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

    context 'When testing AIX 7.1' do
      subject {
        on_supported_os(
            {
                :supported_os => [
                    {
                        "operatingsystem" => "AIX",
                        "operatingsystemrelease" => [
                            "7.1", "7100"
                        ],
                    },
                ],
                :facterversion => '3.9'
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
        # NOTE: See FACT-1827 for details on the IBM,8284-22A part
        # That has to match whatever hardware generated the facts file.
        expect(subject.keys.sort).to eq %w(
          aix-7100-IBM,8284-22A
        )
      end
    end

    context 'When testing Windows', :if => Facter.version.to_f >= 2.4 do
      subject do
        on_supported_os(
          {
            :supported_os => [
              {
                'operatingsystem'        => 'Windows',
                'operatingsystemrelease' => release,
              }
            ],
          }
        )
      end

      context 'with a standard release' do
        let(:release) { ['7'] }

        it { is_expected.to be_a(Hash) }
        it { is_expected.to have_attributes(:size => 1) }
        it { is_expected.to include('windows-7-x64' => an_instance_of(Hash)) }
      end

      context 'with a revision release' do
        let(:release) { ['2012 R2'] }

        it { is_expected.to be_a(Hash) }
        it { is_expected.to have_attributes(:size => 1) }
        it { is_expected.to include('windows-2012 R2-x64' => an_instance_of(Hash)) }
      end

      context 'with a Server prefixed release' do
        let(:release) { ['Server 2012'] }

        it { is_expected.to be_a(Hash) }
        it { is_expected.to have_attributes(:size => 1) }
        it { is_expected.to include('windows-2012-x64' => an_instance_of(Hash)) }
      end

      context 'with a 2016 release' do
        let(:release) { ['2016'] }

        it { is_expected.to be_a(Hash) }
        it { is_expected.to have_attributes(:size => 1) }
        it { is_expected.to include('windows-2016-x64' => an_instance_of(Hash)) }
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
            ],
            :facterversion => '2.4',
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
        expect(subject.keys.sort).to include(a_string_matching(/\Aarchlinux-\d+-x86_64/), 'debian-8-x86_64')
      end
    end

    context 'When the operatingsystemrelease contains parens' do
      subject do
        on_supported_os(
          {
            :supported_os => [
              {
                'operatingsystem'        => 'IOS',
                'operatingsystemrelease' => ['12.2(25)EWA9'],
              }
            ],
          }
        )
      end

      before(:each) do
        allow(RspecPuppetFacts).to receive(:warning).with(a_string_matching(/no facts were found/i))
        allow(FacterDB).to receive(:get_facts).and_call_original
      end

      it 'escapes the parens in the filter' do
        filter = [
          include(
            :operatingsystem        => "IOS",
            :operatingsystemrelease => "/^12\\.2\\(25\\)EWA9/",
            :hardwaremodel          => "x86_64",
          ),
        ]

        expect(FacterDB).to receive(:get_facts).with(filter)
        subject
      end

      it 'does not raise an error' do
        expect { subject }.not_to raise_error
      end
    end

    context 'Without a custom facterversion in the options hash' do
      subject do
        on_supported_os(
          supported_os: [
            { 'operatingsystem' => 'CentOS', 'operatingsystemrelease' => %w[7] }
          ]
        )
      end

      it 'returns facts from the loaded facter version' do
        facter_version = Facter.version.split('.')
        is_expected.to match(
          'centos-7-x86_64' => include(
            :facterversion => /\A#{facter_version[0]}\.#{facter_version[1]}\./
          )
        )
      end
    end

    context 'With a default Facter version specified in the RSpec configuration' do
      before(:each) do
        RSpec.configuration.default_facter_version = '3.1.0'
      end

      after(:each) do
        RSpec.configuration.default_facter_version = Facter.version
      end

      subject do
        on_supported_os(
          supported_os: [
            { 'operatingsystem' => 'CentOS', 'operatingsystemrelease' => %w[7] }
          ]
        )
      end

      it 'returns facts from the specified default Facter version' do
        is_expected.to match(
          'centos-7-x86_64' => include(
            :facterversion => /\A3\.1\./
          )
        )
      end
    end

    context 'With a version that is above the current gem' do
      before(:each) do
        allow(Facter).to receive(:version).and_return('2.4.5')
      end

      subject do
        on_supported_os(
          supported_os: [
            { 'operatingsystem' => 'CentOS', 'operatingsystemrelease' => %w[7] }
          ],
          facterversion: "2.6"
        )
      end

      it 'returns facts from a facter version matching future and below' do
        major, minor = Facter.version.split('.')
        is_expected.to match(
          'centos-7-x86_64' => include(
            :facterversion => /\A#{major}\.[#{minor}#{minor.to_i + 1}]\./
          )
        )
      end

      context 'With SPEC_FACTS_STRICT set to `yes`' do
        before(:each) do
          allow(RspecPuppetFacts).to receive(:spec_facts_strict?).and_return(true)
        end
        it 'errors' do
          expect { subject }.to raise_error ArgumentError, /No facts were found in the FacterDB.*aborting/
        end
      end
    end

    context 'With a custom facterversion (3.1) in the options hash' do
      subject do
        on_supported_os(
          supported_os: [
            { 'operatingsystem' => 'CentOS', 'operatingsystemrelease' => %w[7] }
          ],
          facterversion: '3.1'
        )
      end

      it 'returns facts from a facter version matching 3.1' do
        is_expected.to match(
          'centos-7-x86_64' => include(:facterversion => '3.1.6')
        )
      end
    end

    context 'With a custom facterversion (3.1.2) in the options hash' do
      subject do
        on_supported_os(
          supported_os: [
            { 'operatingsystem' => 'CentOS', 'operatingsystemrelease' => %w[7] }
          ],
          facterversion: '3.1.2'
        )
      end

      it 'returns facts from a facter version matching 3.1' do
        is_expected.to match(
          'centos-7-x86_64' => include(:facterversion => '3.1.6')
        )
      end
    end

    context 'With a custom facterversion (3.3) in the options hash' do
      subject do
        on_supported_os(
          supported_os: [
            { 'operatingsystem' => 'CentOS', 'operatingsystemrelease' => %w[7] }
          ],
          facterversion: '3.3'
        )
      end

      it 'returns facts from a facter version matching 3.3' do
        is_expected.to match(
          'centos-7-x86_64' => include(:facterversion => '3.3.0')
        )
      end
    end

    context 'With a custom facterversion (3.3.2) in the options hash' do
      subject do
        on_supported_os(
          supported_os: [
            { 'operatingsystem' => 'CentOS', 'operatingsystemrelease' => %w[7] }
          ],
          facterversion: '3.3.2'
        )
      end

      it 'returns facts from a facter version matching 3.3' do
        is_expected.to match(
          'centos-7-x86_64' => include(:facterversion => '3.3.0')
        )
      end
    end

    context 'With an invalid facterversion in the options hash' do
      let(:method_call) do
        on_supported_os(
          supported_os: [
            { 'operatingsystem' => 'CentOS', 'operatingsystemrelease' => %w[7] }
          ],
          facterversion: '3'
        )
      end

      it 'raises an error' do
        expect { method_call }.to raise_error(ArgumentError,
                                              /:facterversion must be in the /)
      end
    end

    context 'Downgrades to a facter version with facts per OS' do
      subject do
        on_supported_os(
          supported_os: [
            { 'operatingsystem' => 'CentOS', 'operatingsystemrelease' => %w[7] },
            { 'operatingsystem' => 'OpenSuSE', 'operatingsystemrelease' => %w[42] }
          ],
          facterversion: '3.9.5'
        )
      end

      before(:each) do
        allow(FacterDB).to receive(:get_facts).and_call_original
        allow(FacterDB).to receive(:get_facts).with(
          a_hash_including(facterversion: "/\\A3\\.9\\./", operatingsystem: 'CentOS')
        ).and_return([])
      end

      it 'returns CentOS facts from a facter version matching 3.8' do
        is_expected.to include(
          'centos-7-x86_64' => include(:facterversion => '3.8.0')
        )
      end
      it 'returns OpenSuSE facts from a facter version matching 3.9' do
        is_expected.to include(
          'opensuse-42-x86_64' => include(:facterversion => '3.9.2')
        )
      end
    end
  end

  context '#add_custom_fact' do
    subject {
      on_supported_os(
        {
          :supported_os => [
            {
              "operatingsystem" => "RedHat",
              "operatingsystemrelease" => [
                "6",
                "7"
              ]
            }
          ]
        }
      )
    }

    before(:each) do
      RspecPuppetFacts.reset
    end

    it 'adds a simple fact and value' do
      add_custom_fact 'root_home', '/root'
      expect(subject['redhat-7-x86_64']['root_home']).to eq '/root'
    end

    it 'confines a fact to a particular operating system' do
      add_custom_fact 'root_home', '/root', :confine => 'redhat-7-x86_64'
      expect(subject['redhat-7-x86_64']['root_home']).to eq '/root'
      expect(subject['redhat-6-x86_64']['root_home']).to be_nil
    end

    it 'excludes a fact from a particular operating system' do
      add_custom_fact 'root_home', '/root', :exclude => 'redhat-7-x86_64'
      expect(subject['redhat-7-x86_64']['root_home']).to be_nil
      expect(subject['redhat-6-x86_64']['root_home']).to eq '/root'
    end

    it 'takes a proc as a value' do
      add_custom_fact 'root_home', ->(_os, _facts) { '/root' }
      expect(subject['redhat-7-x86_64']['root_home']).to eq '/root'
    end
  end

  context '#misc' do
    it 'should have a common facts structure' do
      RspecPuppetFacts.reset
      expect(subject.common_facts).to be_a Hash
      expect(subject.common_facts).not_to be_empty
    end

    it 'should not add "augeasversion" if Augeas is supported' do
      allow(described_class).to receive(:augeas?).and_return(false)
      RspecPuppetFacts.reset
      expect(subject.common_facts).not_to include(:augeasversion)
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

      allow(described_class).to receive(:augeas?).and_return(true)
      stub_const('Augeas', Augeas_stub)
      RspecPuppetFacts.reset
      expect(subject.common_facts[:augeasversion]).to eq 'my_version'
    end

    context 'when mcollective is available' do
      module MCollective_stub
        VERSION = 'my_version'
      end

      before(:each) do
        allow(described_class).to receive(:mcollective?).and_return(true)
        stub_const('MCollective', MCollective_stub)
        described_class.reset
      end

      it 'includes an "mco_version" fact' do
        expect(subject.common_facts).to include(:mco_version => 'my_version')
      end
    end

    context 'when mcollective is not available' do
      before(:each) do
        allow(described_class).to receive(:mcollective?).and_return(false)
        described_class.reset
      end

      it 'does not include an "mco_version" fact' do
        expect(subject.common_facts).not_to include(:mco_version)
      end
    end
  end

  describe '.facter_version_to_filter' do
    context 'when passed a version that is major.minor (1)' do
      subject { RspecPuppetFacts.facter_version_to_filter('1.2') }

      it 'returns the correct JGrep statement expression' do
        is_expected.to eq('/\A1\.2\./')
      end
    end

    context 'when passed a version that is major.minor (2)' do
      subject { RspecPuppetFacts.facter_version_to_filter('10.2') }

      it 'returns the correct JGrep statement expression' do
        is_expected.to eq('/\A10\.2\./')
      end
    end

    context 'when passed a version that is major.minor (3)' do
      subject { RspecPuppetFacts.facter_version_to_filter('1.20') }

      it 'returns the correct JGrep statement expression' do
        is_expected.to eq('/\A1\.20\./')
      end
    end

    context 'when passed a version that is major.minor (4)' do
      subject { RspecPuppetFacts.facter_version_to_filter('10.20') }

      it 'returns the correct JGrep statement expression' do
        is_expected.to eq('/\A10\.20\./')
      end
    end

    context 'when passed a version that is major.minor.patch (1)' do
      subject { RspecPuppetFacts.facter_version_to_filter('1.2.3') }

      it 'returns the correct JGrep statement expression' do
        is_expected.to eq('/\A1\.2\./')
      end
    end

    context 'when passed a version that is major.minor.patch (2)' do
      subject { RspecPuppetFacts.facter_version_to_filter('10.2.3') }

      it 'returns the correct JGrep statement expression' do
        is_expected.to eq('/\A10\.2\./')
      end
    end

    context 'when passed a version that is major.minor.patch (3)' do
      subject { RspecPuppetFacts.facter_version_to_filter('1.20.3') }

      it 'returns the correct JGrep statement expression' do
        is_expected.to eq('/\A1\.20\./')
      end
    end

    context 'when passed a version that is major.minor.patch (4)' do
      subject { RspecPuppetFacts.facter_version_to_filter('10.20.3') }

      it 'returns the correct JGrep statement expression' do
        is_expected.to eq('/\A10\.20\./')
      end
    end
  end

  describe '.down_facter_version' do
    context 'with MAJOR.MINOR.PATCH version' do
      it 'decrements MINOR version' do
        expect(RspecPuppetFacts.down_facter_version('3.5.5')).to eq '3.4.5'
      end
    end
    context 'with MAJOR.MINOR version' do
      it 'decrements MINOR version and sets PATCH to \'0\'' do
        expect(RspecPuppetFacts.down_facter_version('3.5')).to eq '3.4.0'
      end
    end
  end
end
