# gem-sweep

This RubyGems plugin provides the `gem sweep` command to clean up unnecessary native extension files from gem installations.

## Features

- **Automatic cleanup**: Automatically removes duplicate native extension files during gem installation
- **Manual cleanup**: Use `gem sweep` command to clean up existing gems
- **Safe operation**: Preserves files in versioned directories (e.g., google-protobuf, nokogiri)

## Usage

### Automatic cleanup during installation

The plugin automatically cleans up extension files when installing gems:

```
$ gem install digest
Fetching digest-3.1.1.gem
Building native extensions. This could take a while...
Delete /Users/hsbt/.local/share/gem/gems/digest-3.1.1/lib/digest/bubblebabble.bundle
Delete /Users/hsbt/.local/share/gem/gems/digest-3.1.1/lib/digest/md5.bundle
Delete /Users/hsbt/.local/share/gem/gems/digest-3.1.1/lib/digest/rmd160.bundle
Delete /Users/hsbt/.local/share/gem/gems/digest-3.1.1/lib/digest/sha1.bundle
Delete /Users/hsbt/.local/share/gem/gems/digest-3.1.1/lib/digest/sha2.bundle
Delete /Users/hsbt/.local/share/gem/gems/digest-3.1.1/lib/digest.bundle
Successfully installed digest-3.1.1
1 gem installed
```

### Manual cleanup with gem sweep command

You can also manually clean up extension files from all installed gems:

```
$ gem sweep
Delete /Users/hsbt/.local/share/gem/gems/some-gem-1.0.0/lib/some_extension.bundle
Delete /Users/hsbt/.local/share/gem/gems/another-gem-2.1.0/lib/another.bundle
...
```

## Installation

```
$ gem install gem-sweep
```

## Background

RubyGems will install native extension files into the following paths:

```
$GEM_HOME/gems/extensions/$arch-$platform-$version/$rubyversion/foo-x.y.z
$GEM_HOME/gems/foo-x.y.z/lib
```

The native extension files in `$GEM_HOME/gems/foo-x.y.z/lib` directory is harmful for us. Because this directory couldn't handle architecture, platform and ruby version. So, We should use native extension files in `$GEM_HOME/gems/extensions/$arch-$platform-$version/$rubyversion/foo-x.y.z` directory, not `$GEM_HOME/gems/foo-x.y.z/lib` directory.
