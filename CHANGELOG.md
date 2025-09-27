# Changelog

## [6.0.0](https://github.com/voxpupuli/rspec-puppet-facts/tree/6.0.0) (2025-09-27)

[Full Changelog](https://github.com/voxpupuli/rspec-puppet-facts/compare/5.4.0...6.0.0)

**Breaking changes:**

- Require Ruby 3.2 or newer [\#224](https://github.com/voxpupuli/rspec-puppet-facts/pull/224) ([bastelfreak](https://github.com/bastelfreak))
- CI: Dont validate puppet\_agent\_facter\_versions.json anymore [\#223](https://github.com/voxpupuli/rspec-puppet-facts/pull/223) ([bastelfreak](https://github.com/bastelfreak))
- Switch from facter to openfact [\#219](https://github.com/voxpupuli/rspec-puppet-facts/pull/219) ([bastelfreak](https://github.com/bastelfreak))

**Implemented enhancements:**

- puppet\_agent\_facter\_versions: Add OpenVox/OpenFact versions [\#228](https://github.com/voxpupuli/rspec-puppet-facts/pull/228) ([bastelfreak](https://github.com/bastelfreak))
- FacterDB: Allow 4.x [\#222](https://github.com/voxpupuli/rspec-puppet-facts/pull/222) ([dependabot[bot]](https://github.com/apps/dependabot))

**Fixed bugs:**

- Fix dependabot configuration [\#226](https://github.com/voxpupuli/rspec-puppet-facts/pull/226) ([bastelfreak](https://github.com/bastelfreak))

**Merged pull requests:**

- README: Fix upstream documentation link to metadata [\#225](https://github.com/voxpupuli/rspec-puppet-facts/pull/225) ([giacomd](https://github.com/giacomd))

## [5.4.0](https://github.com/voxpupuli/rspec-puppet-facts/tree/5.4.0) (2025-06-11)

[Full Changelog](https://github.com/voxpupuli/rspec-puppet-facts/compare/5.3.1...5.4.0)

**Implemented enhancements:**

- Support OpenVox [\#217](https://github.com/voxpupuli/rspec-puppet-facts/pull/217) ([bastelfreak](https://github.com/bastelfreak))
- Make Puppet a soft dependency [\#213](https://github.com/voxpupuli/rspec-puppet-facts/pull/213) ([ekohl](https://github.com/ekohl))
- Add Ruby 3.4 support / generate CI matrix dynamically [\#211](https://github.com/voxpupuli/rspec-puppet-facts/pull/211) ([bastelfreak](https://github.com/bastelfreak))

**Merged pull requests:**

- Drop unused coverage reporting [\#210](https://github.com/voxpupuli/rspec-puppet-facts/pull/210) ([bastelfreak](https://github.com/bastelfreak))

## [5.3.1](https://github.com/voxpupuli/rspec-puppet-facts/tree/5.3.1) (2025-04-29)

[Full Changelog](https://github.com/voxpupuli/rspec-puppet-facts/compare/5.3.0...5.3.1)

**Fixed bugs:**

- Fix compatibility with Ruby 2.7 [\#207](https://github.com/voxpupuli/rspec-puppet-facts/pull/207) ([silug](https://github.com/silug))

## [5.3.0](https://github.com/voxpupuli/rspec-puppet-facts/tree/5.3.0) (2025-04-28)

[Full Changelog](https://github.com/voxpupuli/rspec-puppet-facts/compare/5.2.0...5.3.0)

**Implemented enhancements:**

- Add Puppet 8.12 / Facter 4.12 [\#204](https://github.com/voxpupuli/rspec-puppet-facts/pull/204) ([bastelfreak](https://github.com/bastelfreak))
- Only store facter versions in JSON [\#203](https://github.com/voxpupuli/rspec-puppet-facts/pull/203) ([ekohl](https://github.com/ekohl))

## [5.2.0](https://github.com/voxpupuli/rspec-puppet-facts/tree/5.2.0) (2024-10-30)

[Full Changelog](https://github.com/voxpupuli/rspec-puppet-facts/compare/5.1.0...5.2.0)

**Implemented enhancements:**

- Update components.json with Puppet 8.10.0 [\#200](https://github.com/voxpupuli/rspec-puppet-facts/pull/200) ([bastelfreak](https://github.com/bastelfreak))

**Merged pull requests:**

- Update voxpupuli-rubocop requirement from ~\> 2.8.0 to ~\> 3.0.0 [\#199](https://github.com/voxpupuli/rspec-puppet-facts/pull/199) ([dependabot[bot]](https://github.com/apps/dependabot))

## [5.1.0](https://github.com/voxpupuli/rspec-puppet-facts/tree/5.1.0) (2024-08-13)

[Full Changelog](https://github.com/voxpupuli/rspec-puppet-facts/compare/5.0.0...5.1.0)

**Implemented enhancements:**

- Update components.json with Puppet 8.8.1 [\#197](https://github.com/voxpupuli/rspec-puppet-facts/pull/197) ([bastelfreak](https://github.com/bastelfreak))
- Update components.json with Puppet 8.7.0 [\#195](https://github.com/voxpupuli/rspec-puppet-facts/pull/195) ([bastelfreak](https://github.com/bastelfreak))

**Merged pull requests:**

- Generate a pretty `ext/puppet_agent_components.json` file [\#196](https://github.com/voxpupuli/rspec-puppet-facts/pull/196) ([smortex](https://github.com/smortex))

## [5.0.0](https://github.com/voxpupuli/rspec-puppet-facts/tree/5.0.0) (2024-07-08)

[Full Changelog](https://github.com/voxpupuli/rspec-puppet-facts/compare/4.0.0...5.0.0)

**Breaking changes:**

- Switch to FacterDB 3 / drop legacy facts [\#187](https://github.com/voxpupuli/rspec-puppet-facts/pull/187) ([bastelfreak](https://github.com/bastelfreak))

**Implemented enhancements:**

- Deprecate symbolized facts [\#193](https://github.com/voxpupuli/rspec-puppet-facts/pull/193) ([bastelfreak](https://github.com/bastelfreak))

**Fixed bugs:**

- handle stringified facterversion properly [\#191](https://github.com/voxpupuli/rspec-puppet-facts/pull/191) ([bastelfreak](https://github.com/bastelfreak))

**Merged pull requests:**

- Update voxpupuli-rubocop requirement from ~\> 2.7.0 to ~\> 2.8.0 [\#192](https://github.com/voxpupuli/rspec-puppet-facts/pull/192) ([dependabot[bot]](https://github.com/apps/dependabot))

## [4.0.0](https://github.com/voxpupuli/rspec-puppet-facts/tree/4.0.0) (2024-06-10)

[Full Changelog](https://github.com/voxpupuli/rspec-puppet-facts/compare/3.0.0...4.0.0)

**Breaking changes:**

- Rely on modern facts [\#178](https://github.com/voxpupuli/rspec-puppet-facts/pull/178) ([ekohl](https://github.com/ekohl))
- Require FacterDB 2.x [\#176](https://github.com/voxpupuli/rspec-puppet-facts/pull/176) ([bastelfreak](https://github.com/bastelfreak))

**Implemented enhancements:**

- work with symbolized strings [\#175](https://github.com/voxpupuli/rspec-puppet-facts/pull/175) ([bastelfreak](https://github.com/bastelfreak))

**Merged pull requests:**

- rubocop: Fix Layout cops [\#182](https://github.com/voxpupuli/rspec-puppet-facts/pull/182) ([bastelfreak](https://github.com/bastelfreak))
- Use max\_by to determine the maximum value [\#181](https://github.com/voxpupuli/rspec-puppet-facts/pull/181) ([ekohl](https://github.com/ekohl))
- rubocop: Fix Style cops [\#180](https://github.com/voxpupuli/rspec-puppet-facts/pull/180) ([bastelfreak](https://github.com/bastelfreak))
- Use more native rspec matchers in tests [\#179](https://github.com/voxpupuli/rspec-puppet-facts/pull/179) ([ekohl](https://github.com/ekohl))
- Update voxpupuli-rubocop requirement from ~\> 2.6.0 to ~\> 2.7.0 [\#171](https://github.com/voxpupuli/rspec-puppet-facts/pull/171) ([dependabot[bot]](https://github.com/apps/dependabot))

## [3.0.0](https://github.com/voxpupuli/rspec-puppet-facts/tree/3.0.0) (2024-03-23)

[Full Changelog](https://github.com/voxpupuli/rspec-puppet-facts/compare/2.0.5...3.0.0)

**symbolized facts deprecation**

With the release of rspec-puppet-facts 6.0.0 we will remove support for symbolized facts. At the moment people typically use this in their unit files:

```ruby
on_supported_os.each do |os, os_facts|
  case os_facts[:os]['name']
  when 'Archlinux'
    context 'on Archlinux' do
      it { is_expected.to contain_package('borg') }
    end
  when 'Ubuntu'
  end
end
```

For history reasons the first level of facts were symbols. You will have to update it to strings with the 6.0.0 release:

```ruby
on_supported_os.each do |os, os_facts|
  case os_facts['os']['name']
  when 'Archlinux'
    context 'on Archlinux' do
      it { is_expected.to contain_package('borg') }
    end
  when 'Ubuntu'
  end
end
```

As an alternative you can configure the old behaviour:

```ruby
RSpec.configure do |c|
  c.facterdb_string_keys = false
end
```

**Breaking changes:**

- Use facterdb\_string\_keys configuration option for custom facts [\#157](https://github.com/voxpupuli/rspec-puppet-facts/pull/157) ([jordanbreen28](https://github.com/jordanbreen28))
- Do not query for the exact facter version [\#151](https://github.com/voxpupuli/rspec-puppet-facts/pull/151) ([ekohl](https://github.com/ekohl))
- Drop Ruby 2.4/2.5/2.6 support [\#149](https://github.com/voxpupuli/rspec-puppet-facts/pull/149) ([bastelfreak](https://github.com/bastelfreak))

**Implemented enhancements:**

- Add Ruby 3.3 support [\#169](https://github.com/voxpupuli/rspec-puppet-facts/pull/169) ([bastelfreak](https://github.com/bastelfreak))
- gemspec: Add version constraints & CI: Build gem in strict mode [\#165](https://github.com/voxpupuli/rspec-puppet-facts/pull/165) ([bastelfreak](https://github.com/bastelfreak))
- update puppet agent components [\#164](https://github.com/voxpupuli/rspec-puppet-facts/pull/164) ([bastelfreak](https://github.com/bastelfreak))
- Add merge facts option to add\_custom\_fact [\#160](https://github.com/voxpupuli/rspec-puppet-facts/pull/160) ([jordanbreen28](https://github.com/jordanbreen28))
- Collect facts iteratively [\#152](https://github.com/voxpupuli/rspec-puppet-facts/pull/152) ([ekohl](https://github.com/ekohl))
- Use Hash.to\_h to construct a new hash [\#150](https://github.com/voxpupuli/rspec-puppet-facts/pull/150) ([ekohl](https://github.com/ekohl))
- Add Ruby 3.2 support [\#148](https://github.com/voxpupuli/rspec-puppet-facts/pull/148) ([bastelfreak](https://github.com/bastelfreak))

**Merged pull requests:**

- Update voxpupuli-rubocop requirement from ~\> 2.4.0 to ~\> 2.6.0 [\#168](https://github.com/voxpupuli/rspec-puppet-facts/pull/168) ([dependabot[bot]](https://github.com/apps/dependabot))
- github\_changelog\_generator: Apply best practices [\#163](https://github.com/voxpupuli/rspec-puppet-facts/pull/163) ([bastelfreak](https://github.com/bastelfreak))
- Gemfile: Add faraday as github\_changelog\_generator dep [\#162](https://github.com/voxpupuli/rspec-puppet-facts/pull/162) ([bastelfreak](https://github.com/bastelfreak))
- voxpupuli-rubocop: Pin to patch version [\#161](https://github.com/voxpupuli/rspec-puppet-facts/pull/161) ([bastelfreak](https://github.com/bastelfreak))
- Update voxpupuli-rubocop requirement from ~\> 1.3 to ~\> 2.0 [\#156](https://github.com/voxpupuli/rspec-puppet-facts/pull/156) ([dependabot[bot]](https://github.com/apps/dependabot))
- CI: add dummy job to depend on [\#155](https://github.com/voxpupuli/rspec-puppet-facts/pull/155) ([bastelfreak](https://github.com/bastelfreak))
- migrate to voxpupuli-rubocop [\#154](https://github.com/voxpupuli/rspec-puppet-facts/pull/154) ([bastelfreak](https://github.com/bastelfreak))
- Update rubocop requirement from ~\> 1.48.1 to ~\> 1.54.1 [\#153](https://github.com/voxpupuli/rspec-puppet-facts/pull/153) ([dependabot[bot]](https://github.com/apps/dependabot))
- Introduce RuboCop and fix various cops [\#146](https://github.com/voxpupuli/rspec-puppet-facts/pull/146) ([ekohl](https://github.com/ekohl))
- Update puppet agent components [\#145](https://github.com/voxpupuli/rspec-puppet-facts/pull/145) ([bastelfreak](https://github.com/bastelfreak))

## [2.0.5](https://github.com/voxpupuli/rspec-puppet-facts/tree/2.0.5) (2022-04-22)

[Full Changelog](https://github.com/voxpupuli/rspec-puppet-facts/compare/2.0.4...2.0.5)

**Fixed bugs:**

- fallback to lsb facts if structured facts are nil [\#140](https://github.com/voxpupuli/rspec-puppet-facts/pull/140) ([bastelfreak](https://github.com/bastelfreak))

## [2.0.4](https://github.com/voxpupuli/rspec-puppet-facts/tree/2.0.4) (2022-04-22)

[Full Changelog](https://github.com/voxpupuli/rspec-puppet-facts/compare/2.0.3...2.0.4)

**Fixed bugs:**

- Use structured facts to detect OS version [\#136](https://github.com/voxpupuli/rspec-puppet-facts/pull/136) ([bastelfreak](https://github.com/bastelfreak))

**Merged pull requests:**

- Add Ruby 3.1 to CI [\#138](https://github.com/voxpupuli/rspec-puppet-facts/pull/138) ([bastelfreak](https://github.com/bastelfreak))
- Update puppet components hash [\#137](https://github.com/voxpupuli/rspec-puppet-facts/pull/137) ([bastelfreak](https://github.com/bastelfreak))

## [2.0.3](https://github.com/voxpupuli/rspec-puppet-facts/tree/2.0.3) (2021-09-22)

[Full Changelog](https://github.com/voxpupuli/rspec-puppet-facts/compare/2.0.2...2.0.3)

**Merged pull requests:**

- regenerate puppet\_agent\_components.json [\#133](https://github.com/voxpupuli/rspec-puppet-facts/pull/133) ([bastelfreak](https://github.com/bastelfreak))

## [2.0.2](https://github.com/voxpupuli/rspec-puppet-facts/tree/2.0.2) (2021-07-21)

[Full Changelog](https://github.com/voxpupuli/rspec-puppet-facts/compare/2.0.1...2.0.2)

**Implemented enhancements:**

- Implement github action testing and codecov coverage reporting [\#129](https://github.com/voxpupuli/rspec-puppet-facts/pull/129) ([bastelfreak](https://github.com/bastelfreak))

**Merged pull requests:**

- Move facterversion\_obj declaration out of the loop [\#131](https://github.com/voxpupuli/rspec-puppet-facts/pull/131) ([ekohl](https://github.com/ekohl))
- Upgrade to GitHub-native Dependabot [\#126](https://github.com/voxpupuli/rspec-puppet-facts/pull/126) ([dependabot-preview[bot]](https://github.com/apps/dependabot-preview))

## [2.0.1](https://github.com/voxpupuli/rspec-puppet-facts/tree/2.0.1) (2021-01-09)

[Full Changelog](https://github.com/voxpupuli/rspec-puppet-facts/compare/2.0.0...2.0.1)

**Closed issues:**

- Memoizing facts [\#114](https://github.com/voxpupuli/rspec-puppet-facts/issues/114)
- Commit 21442e7 looks to introduce hard to debug behavior [\#97](https://github.com/voxpupuli/rspec-puppet-facts/issues/97)

**Merged pull requests:**

- Implement fact memoization [\#122](https://github.com/voxpupuli/rspec-puppet-facts/pull/122) ([ekohl](https://github.com/ekohl))

## [2.0.0](https://github.com/voxpupuli/rspec-puppet-facts/tree/2.0.0) (2020-08-05)

- Require Ruby >= 2.4
- Automatically find the latest facter version in the database. Previously a
  very slow and undeterministic approach was taken when an exact match of the
  Facter version wasn't found.. The new approach is to take the closest version
  that is still older than the specified version.
- Fix Amazon Linux 2 fact lookup
- Log which facts could not be found
- Remove json as a dependency

## 2019-12-11 - Release 1.10.0
- Automatically select the default Facter version based on the Puppet version.
  The available Puppet version is matched against a mapping of Puppet and
  Facter versions included in the `puppet-agent` all-in-one packages to find
  the most suitable Facter version.

## 2019-07-31 - Release 1.9.6
- Suppress the warning message generated when the Augeas gem is not available.
- Searching through older Facter releases for a fact set that does not exist no
  longer causes it to hang indefinitely.
- The `operatingsystemrelease` values are now correctly escaped when building
  the FacterDB filters, allowing the use of `operatingsystemrelease` values
  that contain special regular expression characters like parentheses.

## 2019-07-29 - Release 1.9.5
- The default version of Facter to search for is now configurable with
  `RSpec.configuration.default_facter_version`.
- When passing a `:supported_os` hash to `on_supported_os()`, single
  `operatingsystemrelease` values can now be specified as a String rather than
  an Array with a single String.
- Dependency on the `mcollective-client` gem removed. The `mco_version` fact
  will now optionally be set if the gem is installed.
- The fact names can now be provided to tests as Strings instead of Symbols by
  setting `RSpec.configuration.facterdb_string_keys` to `true`.
- Dropped support for Ruby < 2.1.0

## 2019-03-22 - Release 1.9.4
- Take two on getting rubygems autodeploy going. So much for docs,
    looking at other projects for this one.
## 2019-03-22 - Release 1.9.3
- Various CI updates - [Garrett Honeycutt](https://github.com/ghoneycutt/)
- Symbolize hash keys in `register_custom_fact`
  [https://github.com/mcanevet/rspec-puppet-facts/pull/77](https://github.com/mcanevet/rspec-puppet-facts/pull/77)

## 2018-10-24 - Release 1.9.2
- Catch the right `LoadError` on missing augeas gem. Thanks to [baurmatt](https://github.com/baurmatt) for the quick fix, and [rodjek](https://github.com/rodjek) for dealing with the testing

## 2018-10-24 - Release 1.9.1
- Do not rely on features of Augeas because Puppet 6

## 2018-01-31 - Release 1.9.0
- Bumps facterdb requirement to 0.5.0
- Adds docs for using custom external facts
- hardwaremodel output changed on Windows with Facter 3.x
- Add additional rqspec tests
- Correctly select windows releases that contain spaces
- Facter < 3.4 does not return a proper release name for Windows 2016
- Strip 'Server' prefix from windows release name if present
- Downcase windows to match facter output
- Fix specs for current facterdb release
- Make version fallback testing independent of installed facter gem
- Add SPEC_FACTS_STRICT setting
- Cleanup README
- Add specific test to test minor version ahead of current facter version
- Update test to check for range in case facter version is not currently in FacterDB
- Step down through versions if the current version is not available
- Fix wrong example in README

## 2017-06-23 - Release 1.8.0
- Support specifying facter version

## 2017-01-04 - Release 1.7.1
- Ignore case when choosing H/W models

## 2016-09-16 - Release 1.7.0
- Support custom facts defined by spec_helper

## 2016-05-19 - Release 1.6.1
- Fix a bug where not all specified Ubuntu or OpenBSD were captured

## 2016-05-17 - Release 1.6.0
- Cleanup and refactor methods
- Add YARD documentation
- Refactor and fix rspec
- Add the OS filter support

## 2016-03-29 - Release 1.5.0
- Add some Microsft Windows support

## 2016-02-04 - Release 1.4.1
- Add missing mcollective-client dependency

## 2016-02-04 - Release 1.4.0
- Dynamically set mco_version

## 2015-11-12 - Release 1.3.0
- Dynamically set rubysitedir

## 2015-11-05 - Release 1.2.0
- Requires facterdb 0.3.0

## 2015-09-15 - Release 1.1.1
- Fix OpenBSD support

## 2015-09-09 - Release 1.1.0
- Populate augeasversion, puppetversion and rubyversion

## 2015-09-03 - Release 1.0.3
- Fix FreeBSD support

## 2015-08-31 - Release 1.0.2
- Keys where not symbolized anymore since v1.0.0

## 2015-08-29 - Release 1.0.1
- Fix for old versions of Facter that does not provide operatingsystemmajrelease for some OSes

## 2015-08-27 - Release 1.0.0
- Use facterdb

## 2015-08-10 - Release 0.12.0
- Add Facter3 support

## 2015-06-16 - Release 0.11.0
- Add facts for OpenBSD 5.7

## 2015-05-27 - Release 0.10.0
- Add facts for Solaris 11

## 2015-05-26 - Release 0.9.0
- Add facts for Ubuntu 14.10
- Add facts for Ubuntu 15.04

## 2015-04-27 - Release 0.8.0
- Remove support for Operating System minor release (causes problems with Ubuntu naming)
- Add Gentoo support

## 2015-04-26 - Release 0.7.0
- Add support for Operating System minor release
- Update README.md

## 2015-03-06 - Release 0.6.0
- Add facts for FreeBSD 9

## 2015-03-06 - Release 0.5.0
- Add facts for FreeBSD 10

## 2015-02-22 - Release 0.4.1
- Really useless release :-)

## 2015-01-23 - Release 0.4.0
- Add facts for facter 2.4
- Format json with python's json.tool
- Improve code coverage in unit tests
- Test on more version of facter in travis matrix

## 2015-01-05 - Release 0.3.3
- Add facts for OpenSuse 12
- Add facts for OpenSuse 13

## 2015-01-04 - Release 0.3.2
* Symbolize hash keys

## 2015-01-03 - Release 0.3.1
- Set fqdn to foo.example.com
- Add json as runtime dependency

## 2015-01-02 - Release 0.3.0
- Use json output for facter

## 2014-12-20 - Release 0.2.5
- Don't fail if facts not found

## 2014-12-20 - Release 0.2.4
- Add facts for SLES 11
- Add facts for Ubuntu 10.04
- Fix for SLES 11 SP1

## 2014-12-20 - Release 0.2.3
- Add facts for ArchLinux

## 2014-12-19 - Release 0.2.2
- Fix some bugs
- Add unit tests

## 2014-12-19 - Release 0.2.1
- Add facts for Debian 8

## 2014-12-15 - Release 0.2.0
- Add opts hash parameter
- Tests only with x86_64 by default

## 2014-12-12 - Release 0.1.4
- Fix for Ubuntu

## 2014-12-12 - Release 0.1.4
- Fix for Fedora

## 2014-12-12 - Release 0.1.3
- Add facts for Fedora 19

## 2014-12-12 - Release 0.1.2
- Add facts for Scientific Linux

## 2014-12-12 - Release 0.1.1
- Add more facts

## 2014-12-12 - First Release 0.1.0
- Initial release


\* *This Changelog was automatically generated by [github_changelog_generator](https://github.com/github-changelog-generator/github-changelog-generator)*
