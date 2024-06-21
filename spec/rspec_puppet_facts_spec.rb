require 'spec_helper'
require 'json'
require 'stringio'

describe RspecPuppetFacts do
  let(:metadata_file) do
    'spec/fixtures/metadata.json'
  end

  describe '.stringify_keys' do
    it {
      expect(described_class.stringify_keys({ os: { family: 'RedHat' } })).to eq({ 'os' => { 'family' => 'RedHat' } })
    }
  end

  describe '.facter_version_for_puppet_version' do
    subject(:facter_version) do
      described_class.facter_version_for_puppet_version(puppet_version)
    end

    let(:component_json_path) do
      File.expand_path(File.join(__dir__, '..', 'ext', 'puppet_agent_components.json'))
    end

    let(:puppet_version) { Puppet.version }

    context 'when the component JSON file does not exist' do
      before do
        allow(File).to receive(:file?).with(component_json_path).and_return(false)
        allow(described_class).to receive(:warning)
      end

      it 'defaults to the currently installed Facter version' do
        expect(facter_version).to eq(Facter.version)
      end

      it 'warns the user' do
        msg = /does not exist or is not readable, defaulting to/i
        expect(described_class).to receive(:warning).with(a_string_matching(msg))
        facter_version
      end
    end

    context 'when the component JSON file is unreadable' do
      before do
        allow(File).to receive(:readable?).with(component_json_path).and_return(false)
        allow(described_class).to receive(:warning)
      end

      it 'defaults to the currently installed Facter version' do
        expect(facter_version).to eq(Facter.version)
      end

      it 'warns the user' do
        msg = /does not exist or is not readable, defaulting to/i
        expect(described_class).to receive(:warning).with(a_string_matching(msg))
        facter_version
      end
    end

    context 'when the component JSON file is unparseable' do
      before do
        io = StringIO.new('this is not JSON!')
        allow(File).to receive(:open).with(component_json_path, anything).and_return(io)
        allow(described_class).to receive(:warning)
      end

      it 'defaults to the currently installed Facter version' do
        expect(facter_version).to eq(Facter.version)
      end

      it 'warns the user' do
        msg = /contains invalid json, defaulting to/i
        expect(described_class).to receive(:warning).with(a_string_matching(msg))
        facter_version
      end
    end

    context 'when the passed puppet_version is nil' do
      let(:puppet_version) { nil }

      it 'defaults to the currently installed Facter version' do
        expect(facter_version).to eq(Facter.version)
      end
    end

    context 'when passed a Puppet version greater than any known version' do
      let(:puppet_version) { '999.0.0' }

      it 'returns the Facter version for the highest known Puppet version' do
        known_facter_versions = JSON.parse(File.read(component_json_path)).map do |_, r|
          r['facter']
        end
        sorted_facter_versions = known_facter_versions.compact.sort do |a, b|
          Gem::Version.new(b) <=> Gem::Version.new(a)
        end

        expect(facter_version).to eq(sorted_facter_versions.first)
      end
    end

    context 'when passed a known Puppet version' do
      let(:puppet_version) { '5.2.0' }

      it 'returns the Facter version for that Puppet version' do
        expect(facter_version).to eq('3.9.0')
      end
    end

    context 'when passed a Puppet version between two known versions' do
      let(:puppet_version) { '5.2.5' }

      it 'returns the Facter version for the lower Puppet version' do
        expect(facter_version).to eq('3.9.0')
      end
    end

    context 'when passed a Puppet version lower than any known version' do
      let(:puppet_version) { '1.0.0' }

      before do
        allow(described_class).to receive(:warning)
      end

      it 'returns the currently installed Facter version' do
        expect(facter_version).to eq(Facter.version)
      end

      it 'warns the user' do
        msg = /unable to find puppet #{Regexp.escape(puppet_version)}.+?, defaulting to/i
        expect(described_class).to receive(:warning).with(a_string_matching(msg))
        facter_version
      end
    end
  end

  describe '#on_supported_os' do
    context 'With RSpec.configuration.facterdb_string_keys' do
      subject(:result) do
        on_supported_os(
          {
            supported_os: [
              {
                'operatingsystem' => 'Debian',
                'operatingsystemrelease' => ['12'],
              },
            ],
          },
        )
      end

      let(:get_keys) do
        proc { |r| r.keys + r.select { |_, v| v.is_a?(Hash) }.map { |_, v| get_keys.call(v) }.flatten }
      end

      context 'set to true' do
        before do
          RSpec.configuration.facterdb_string_keys = true
        end

        after do
          RSpec.configuration.facterdb_string_keys = false
        end

        it 'returns a fact set with all the keys as Strings' do
          expect(get_keys.call(result['debian-12-x86_64'])).to all(be_a(String))
        end
      end

      context 'set to false' do
        before do
          RSpec.configuration.facterdb_string_keys = false
        end

        it 'returns a fact set with all the keys as Symbols or Strings' do
          expect(get_keys.call(result['debian-12-x86_64'])).to all(be_a(Symbol).or(be_a(String)))
        end
      end
    end

    context 'Without specifying supported_os' do
      subject { on_supported_os }

      context 'Without metadata.json' do
        before do
          expect(File).to receive(:file?).with('metadata.json').and_return false
        end

        it { expect { subject }.to raise_error(StandardError, /Can't find metadata.json/) }
      end

      context 'With a metadata.json' do
        it 'can load the metadata file' do
          allow(described_class).to receive(:metadata_file).and_return(metadata_file)
          described_class.reset
          expect(described_class.metadata).to be_a Hash
          expect(described_class.metadata['name']).to eq 'mcanevet-mymodule'
        end

        context 'With a valid metadata.json' do
          let(:metadata) do
            fixture = File.read(metadata_file)
            JSON.parse fixture
          end

          before do
            allow(described_class).to receive(:metadata).and_return(metadata)
          end

          it 'returns a hash' do
            is_expected.to be_a Hash
          end

          it 'returns supported OS' do
            expect(subject.keys).to contain_exactly(
              'debian-11-x86_64',
              'debian-12-x86_64',
              'redhat-8-x86_64',
              'redhat-9-x86_64',
            )
          end

          it 'is able to filter the received OS facts' do
            allow(described_class).to receive(:spec_facts_os_filter).and_return('redhat')
            expect(subject.keys).to contain_exactly(
              'redhat-8-x86_64',
              'redhat-9-x86_64',
            )
          end
        end

        context 'With a broken metadata.json' do
          before do
            allow(described_class).to receive(:metadata).and_return(metadata)
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
      subject do
        on_supported_os(
          {
            supported_os: [
              {
                'operatingsystem' => 'Debian',
                'operatingsystemrelease' => %w[
                  11
                  12
                ],
              },
              {
                'operatingsystem' => 'RedHat',
                'operatingsystemrelease' => %w[
                  8
                  9
                ],
              },
            ],
          },
        )
      end

      it 'returns a hash' do
        is_expected.to be_a Hash
      end

      it 'returns supported OS' do
        expect(subject.keys).to contain_exactly(
          'debian-11-x86_64',
          'debian-12-x86_64',
          'redhat-8-x86_64',
          'redhat-9-x86_64',
        )
      end

      it 'is able to filter the received OS facts' do
        allow(described_class).to receive(:spec_facts_os_filter).and_return('redhat')
        expect(subject.keys).to contain_exactly(
          'redhat-8-x86_64',
          'redhat-9-x86_64',
        )
      end
    end

    context 'When specifying a supported_os with a single release as a String' do
      subject(:factsets) do
        on_supported_os(
          {
            supported_os: [
              { 'operatingsystem' => 'RedHat', 'operatingsystemrelease' => '9' },
            ],
          },
        )
      end

      it 'returns a Hash' do
        expect(factsets).to be_a(Hash)
      end

      it 'returns a fact set for the specified release' do
        expect(factsets).to a_hash_including('redhat-9-x86_64' => hash_including({ os: hash_including({ 'release' => hash_including({ 'major' => '9' }) }) }))
      end
    end

    context 'When testing Ubuntu' do
      subject do
        on_supported_os(
          {
            supported_os: [
              {
                'operatingsystem' => 'Ubuntu',
                'operatingsystemrelease' => [
                  '18.04',
                  '20.04',
                  '22.04',
                ],
              },
            ],
          },
        )
      end

      it 'returns a hash' do
        expect(subject).to be_a Hash
      end

      it 'returns supported OS' do
        expect(subject.keys).to contain_exactly(
          'ubuntu-18.04-x86_64',
          'ubuntu-20.04-x86_64',
          'ubuntu-22.04-x86_64',
        )
      end
    end

    context 'When testing FreeBSD 10' do
      subject do
        on_supported_os(
          {
            supported_os: [
              {
                'operatingsystem' => 'FreeBSD',
                'operatingsystemrelease' => [
                  '13',
                ],
              },
            ],
            facterversion: '4.5',
          },
        )
      end

      it 'returns a hash' do
        expect(subject).to be_a Hash
      end

      it 'returns supported OS' do
        expect(subject.keys).to contain_exactly(
          'freebsd-13-amd64',
        )
      end
    end

    context 'When testing OpenBSD' do
      subject do
        on_supported_os(
          {
            supported_os: [
              {
                'operatingsystem' => 'OpenBSD',
                'operatingsystemrelease' => [
                  '7.5',
                ],
              },
            ],
            facterversion: '4.7',
          },
        )
      end

      it 'returns a hash' do
        expect(subject).to be_a Hash
      end

      it 'returns supported OS' do
        expect(subject.keys).to contain_exactly(
          'openbsd-7-amd64',
        )
      end
    end

    context 'When testing Solaris 11' do
      subject do
        on_supported_os(
          {
            supported_os: [
              {
                'operatingsystem' => 'Solaris',
                'operatingsystemrelease' => [
                  '11',
                ],
              },
            ],
            facterversion: '4.0',
          },
        )
      end

      it 'returns a hash' do
        expect(subject).to be_a Hash
      end

      it 'returns supported OS' do
        pending('2024-06-07: we dont have a suitable solaris 11 factset in facterdb')
        expect(subject.keys).to contain_exactly(
          'solaris-11-i86pc',
        )
      end
    end

    context 'When testing AIX 7.1' do
      subject do
        on_supported_os(
          {
            supported_os: [
              {
                'operatingsystem' => 'AIX',
                'operatingsystemrelease' => [
                  '7.1', '7100',
                ],
              },
            ],
            facterversion: '3.9',
          },
        )
      end

      it 'returns a hash' do
        expect(subject).to be_a Hash
      end

      it 'returns supported OS' do
        # NOTE: See FACT-1827 for details on the IBM,8284-22A part
        # That has to match whatever hardware generated the facts file.
        pending('2024-06-07: we dont have a suitable solaris 11 factset in facterdb')
        expect(subject.keys).to contain_exactly(
          'aix-7100-IBM,8284-22A',
        )
      end
    end

    context 'When testing Windows' do
      subject do
        on_supported_os(
          {
            supported_os: [
              {
                'operatingsystem' => 'Windows',
                'operatingsystemrelease' => release,
              },
            ],
            facterversion: facterversion,
          },
        )
      end

      let(:facterversion) { '4.2' }

      context 'with a standard release' do
        let(:release) { ['10'] }

        it { is_expected.to be_a(Hash) }
        it { is_expected.to match('windows-10-x86_64' => an_instance_of(Hash)) }
      end

      context 'with a revision release' do
        let(:release) { ['2012 R2'] }

        it { is_expected.to be_a(Hash) }
        it { is_expected.to match('windows-2012 R2-x86_64' => an_instance_of(Hash)) }
      end

      context 'with a Server prefixed release' do
        let(:release) { ['Server 2012'] }

        it { is_expected.to be_a(Hash) }
        it { is_expected.to match('windows-2012-x86_64' => an_instance_of(Hash)) }
      end

      context 'with a 2016 release' do
        let(:release) { ['2016'] }

        it { is_expected.to be_a(Hash) }
        it { is_expected.to match('windows-2016-x86_64' => an_instance_of(Hash)) }
      end
    end

    context 'When operatingsystemrelease has space' do
      subject do
        on_supported_os(
          {
            supported_os: [
              {
                'operatingsystem' => 'SLES',
                'operatingsystemrelease' => [
                  '11 SP1',
                ],
              },
            ],
          },
        )
      end

      it 'returns a hash' do
        expect(subject).to be_a Hash
      end

      it 'returns supported OS' do
        pending('2024-06-7: facterdb has no factset with space in the system release')
        expect(subject.keys).to contain_exactly('sles-11-x86_64')
      end
    end

    context 'When specifying wrong supported_os' do
      subject do
        on_supported_os(
          {
            supported_os: [
              {
                'operatingsystem' => 'Debian',
                'operatingsystemrelease' => [
                  '4',
                ],
              },
            ],
          },
        )
      end

      it 'outputs warning message' do
        expect(described_class).to receive(:warning).with(/No facts were found in the FacterDB/)
        subject
      end
    end

    context 'When specifying rolling release operating system' do
      subject do
        on_supported_os(
          {
            supported_os: [
              {
                'operatingsystem' => 'Debian',
                'operatingsystemrelease' => [
                  '12',
                ],
              },
              {
                'operatingsystem' => 'Gentoo',
              },
            ],
            facterversion: '4.6',
          },
        )
      end

      it 'returns a hash' do
        expect(subject).to be_a Hash
      end

      it 'returns supported OS' do
        expect(subject.keys).to contain_exactly(a_string_matching(/gentoo-\d+-x86_64/), 'debian-12-x86_64')
      end
    end

    context 'When the operatingsystemrelease contains parens' do
      subject do
        on_supported_os(
          {
            supported_os: [
              {
                'operatingsystem' => 'IOS',
                'operatingsystemrelease' => ['12.2(25)EWA9'],
              },
            ],
          },
        )
      end

      before do
        allow(described_class).to receive(:warning).with(a_string_matching(/no facts were found/i))
      end

      it 'escapes the parens in the filter' do
        filter = {
          'os.name' => 'IOS',
          'os.release.full' => '/^12\\.2\\(25\\)EWA9/',
          'os.hardware' => 'x86_64',
        }

        expect(FacterDB).to receive(:get_facts).with(filter, symbolize_keys: true).once
        subject
      end

      it 'does not raise an error' do
        expect { subject }.not_to raise_error
      end
    end

    context 'With a default Facter version specified in the RSpec configuration' do
      subject do
        on_supported_os(
          supported_os: [
            { 'operatingsystem' => 'CentOS', 'operatingsystemrelease' => %w[9] },
          ],
        )
      end

      before do
        RSpec.configuration.default_facter_version = '4.6.1'
      end

      after do
        RSpec.configuration.default_facter_version = Facter.version
      end

      it 'returns facts from the specified default Facter version' do
        is_expected.to match(
          'centos-9-x86_64' => include(
            facterversion: /\A4\.6\./,
          ),
        )
      end
    end

    context 'With a version that is above the current gem' do
      subject do
        on_supported_os(
          supported_os: [
            { 'operatingsystem' => 'CentOS', 'operatingsystemrelease' => %w[9] },
          ],
          facterversion: '4.7.99',
        )
      end

      before do
        allow(Facter).to receive(:version).and_return('4.6')
      end

      it 'returns facts from a facter version matching version and below' do
        is_expected.to match(
          'centos-9-x86_64' => include(
            facterversion: /\A4\.[0-7]\./,
          ),
        )
      end

      context 'With SPEC_FACTS_STRICT set to `yes`' do
        before do
          allow(described_class).to receive(:spec_facts_strict?).and_return(true)
        end

        it 'errors' do
          expect { subject }.to raise_error ArgumentError, /No facts were found in the FacterDB.*aborting/
        end
      end
    end

    context 'With a custom facterversion (4.6) in the options hash' do
      subject do
        on_supported_os(
          supported_os: [
            { 'operatingsystem' => 'CentOS', 'operatingsystemrelease' => %w[9] },
          ],
          facterversion: '4.6',
        )
      end

      it 'returns facts from a facter version matching 4.6' do
        is_expected.to match('centos-9-x86_64' => include(facterversion: '4.6.1'))
      end
    end

    context 'With a custom facterversion (4.6.1) in the options hash' do
      subject do
        on_supported_os(
          supported_os: [
            { 'operatingsystem' => 'CentOS', 'operatingsystemrelease' => %w[9] },
          ],
          facterversion: '4.6.1',
        )
      end

      it 'returns facts from a facter version matching 4.6.1' do
        is_expected.to match('centos-9-x86_64' => include(facterversion: '4.6.1'))
      end
    end

    context 'With an invalid facterversion in the options hash' do
      let(:method_call) do
        on_supported_os(
          supported_os: [
            { 'operatingsystem' => 'CentOS', 'operatingsystemrelease' => %w[7] },
          ],
          facterversion: '3',
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
            { 'operatingsystem' => 'CentOS', 'operatingsystemrelease' => %w[9] },
            { 'operatingsystem' => 'Debian', 'operatingsystemrelease' => %w[12] },
          ],
          facterversion: '4.6.1',
        )
      end

      before do
        allow(FacterDB).to receive(:get_facts).and_call_original
        allow(FacterDB).to receive(:get_facts).with(
          { 'os.name' => 'CentOS', 'os.release.full' => '/^9/', 'os.hardware' => 'x86_64' }, symbolize_keys: true
        ).and_wrap_original do |m, *args|
          m.call(*args).reject { |facts| facts[:facterversion].start_with?('4.6.') }
        end
      end

      it 'returns CentOS facts from a facter version matching 4.5' do
        is_expected.to include('centos-9-x86_64' => include(facterversion: '4.5.2'))
      end

      it 'returns Debian facts from a facter version matching 4.6.1' do
        is_expected.to include('debian-12-x86_64' => include(facterversion: '4.6.1'))
      end
    end
  end

  describe '#add_custom_fact' do
    subject do
      on_supported_os(
        {
          supported_os: [
            {
              'operatingsystem' => 'RedHat',
              'operatingsystemrelease' => %w[
                8
                9
              ],
            },
          ],
        },
      )
    end

    before do
      described_class.reset
    end

    it 'adds a simple fact and value' do
      add_custom_fact 'root_home', '/root'
      expect(subject['redhat-9-x86_64'][:root_home]).to eq '/root'
    end

    it 'merges a fact value into fact when merge_facts passed' do
      add_custom_fact :identity, { 'user' => 'test_user' }, merge_facts: true
      expect(subject['redhat-9-x86_64'][:identity]).to eq(
        {
          'gid' => 0,
          'group' => 'root',
          'privileged' => true,
          'uid' => 0,
          'user' => 'test_user',
        },
      )
    end

    it 'overwrites fact' do
      add_custom_fact :identity, { 'user' => 'other_user' }
      expect(subject['redhat-9-x86_64'][:identity]).to eq(
        {
          'user' => 'other_user',
        },
      )
    end

    it 'confines a fact to a particular operating system' do
      add_custom_fact 'root_home', '/root', confine: 'redhat-9-x86_64'
      expect(subject['redhat-9-x86_64'][:root_home]).to eq '/root'
      expect(subject['redhat-8-x86_64'][:root_home]).to be_nil
    end

    it 'excludes a fact from a particular operating system' do
      add_custom_fact 'root_home', '/root', exclude: 'redhat-9-x86_64'
      expect(subject['redhat-9-x86_64'][:root_home]).to be_nil
      expect(subject['redhat-8-x86_64'][:root_home]).to eq '/root'
    end

    it 'takes a proc as a value' do
      add_custom_fact 'root_home', ->(_os, _facts) { '/root' }
      expect(subject['redhat-9-x86_64'][:root_home]).to eq '/root'
    end

    it 'accepts sym fact key and stores fact key as sym' do
      add_custom_fact :root_home, ->(_os, _facts) { '/root' }
      expect(subject['redhat-9-x86_64'][:root_home]).to eq '/root'
    end
  end

  describe '#misc' do
    it 'has a common facts structure' do
      described_class.reset
      expect(subject.common_facts).to be_a Hash
      expect(subject.common_facts).not_to be_empty
    end

    it 'does not add "augeasversion" if Augeas is supported' do
      allow(described_class).to receive(:augeas?).and_return(false)
      described_class.reset
      expect(subject.common_facts).not_to include(:augeasversion)
    end

    it 'determines the Augeas version if Augeas is supported' do
      module AugeasStub # rubocop:todo Lint/ConstantDefinitionInBlock
        NO_MODL_AUTOLOAD = true
        def self.open(*_args)
          self
        end

        def self.get(*_args)
          'my_version'
        end
      end

      allow(described_class).to receive(:augeas?).and_return(true)
      stub_const('Augeas', AugeasStub)
      described_class.reset
      expect(subject.common_facts[:augeasversion]).to eq 'my_version'
    end

    context 'when mcollective is available' do
      module MCollectiveStub # rubocop:todo Lint/ConstantDefinitionInBlock
        VERSION = 'my_version'
      end

      before do
        allow(described_class).to receive(:mcollective?).and_return(true)
        stub_const('MCollective', MCollectiveStub)
        described_class.reset
      end

      it 'includes an "mco_version" fact' do
        expect(subject.common_facts).to include(mco_version: 'my_version')
      end
    end

    context 'when mcollective is not available' do
      before do
        allow(described_class).to receive(:mcollective?).and_return(false)
        described_class.reset
      end

      it 'does not include an "mco_version" fact' do
        expect(subject.common_facts).not_to include(:mco_version)
      end
    end
  end

  describe '.facter_version_to_strict_requirement' do
    subject { described_class.facter_version_to_strict_requirement(version) }

    context 'when passed a version that is a complex requirement' do
      let(:version) { '~> 2.4' }

      it { is_expected.to be_instance_of(Gem::Requirement) }
    end

    context 'when passed a version that is major' do
      let(:version) { '1' }

      it { is_expected.to be_instance_of(Gem::Requirement) }
    end
  end

  describe '.facter_version_to_strict_requirement_string' do
    subject { described_class.facter_version_to_strict_requirement_string(version) }

    context 'when passed a version that is a complex requirement' do
      let(:version) { '~> 2.4' }

      it { is_expected.to eq('~> 2.4') }
    end

    context 'when passed a version that is major' do
      let(:version) { '1' }

      it { is_expected.to eq('~> 1.0') }
    end

    context 'when passed a version that is major.minor' do
      let(:version) { '1.2' }

      it { is_expected.to eq('~> 1.2.0') }
    end

    context 'when passed a version that is major.minor.patch' do
      let(:version) { '1.2.3' }

      it { is_expected.to eq('~> 1.2.3.0') }
    end
  end

  describe '.facter_version_to_loose_requirement' do
    subject { described_class.facter_version_to_loose_requirement(version) }

    context 'when passed a version that is a complex requirement' do
      let(:version) { '~> 2.4' }

      it { is_expected.to be_nil }
    end

    context 'when passed a version that is major' do
      let(:version) { '1' }

      it { is_expected.to be_instance_of(Gem::Requirement) }
    end
  end

  describe '.facter_version_to_loose_requirement_string' do
    subject { described_class.facter_version_to_loose_requirement_string(version) }

    context 'when passed a version that is a complex requirement (1)' do
      let(:version) { '~> 2.4' }

      it { is_expected.to be_nil }
    end

    context 'when passed a version that is a complex requirement (2)' do
      let(:version) { '>= 3 < 5' }

      it { is_expected.to be_nil }
    end

    context 'when passed a version that is major (1)' do
      let(:version) { '1' }

      it { is_expected.to eq('< 2') }
    end

    context 'when passed a version that is major (2)' do
      let(:version) { '9' }

      it { is_expected.to eq('< 10') }
    end

    context 'when passed a version that is major (3)' do
      let(:version) { '10' }

      it { is_expected.to eq('< 11') }
    end

    context 'when passed a version that is major.minor (1)' do
      let(:version) { '1.2' }

      it { is_expected.to eq('< 1.3') }
    end

    context 'when passed a version that is major.minor (2)' do
      let(:version) { '10.2' }

      it { is_expected.to eq('< 10.3') }
    end

    context 'when passed a version that is major.minor (3)' do
      let(:version) { '1.20' }

      it { is_expected.to eq('< 1.21') }
    end

    context 'when passed a version that is major.minor (4)' do
      let(:version) { '10.20' }

      it { is_expected.to eq('< 10.21') }
    end

    context 'when passed a version that is major.minor.patch (1)' do
      let(:version) { '1.2.3' }

      it { is_expected.to eq('< 1.3') }
    end

    context 'when passed a version that is major.minor.patch (2)' do
      let(:version) { '10.2.3' }

      it { is_expected.to eq('< 10.3') }
    end

    context 'when passed a version that is major.minor.patch (3)' do
      let(:version) { '1.20.3' }

      it { is_expected.to eq('< 1.21') }
    end

    context 'when passed a version that is major.minor.patch (4)' do
      let(:version) { '10.20.3' }

      it { is_expected.to eq('< 10.21') }
    end
  end
end
