# gem-sweep

This RubyGems plugin provides the `gem sweep` command to clean up unnecessary native extension files from gem installations.

## Features

- **Automatic cleanup**: Automatically removes duplicate native extension files during gem installation
- **Manual cleanup**: Use `gem sweep` command to clean up existing gems
- **Safe operation**: Preserves files in versioned directories (e.g., google-protobuf, nokogiri)
- **Aggressive mode**: Option to also remove development directories (test, spec, features, tmp)
- **Dry run mode**: Preview what would be deleted without actually removing files

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

```bash
$ gem sweep
Delete /Users/hsbt/.local/share/gem/gems/some-gem-1.0.0/lib/some_extension.bundle
Delete /Users/hsbt/.local/share/gem/gems/another-gem-2.1.0/lib/another.bundle
...
```

#### Command options

- `--aggressive` or `-a`: Also remove test, spec, features directories and tmp directories
- `--dryrun` or `-n`: Show what would be deleted without actually deleting files

**Dry run mode:**
```bash
$ gem sweep --dryrun
Dry run mode: showing what would be deleted

Would delete /Users/hsbt/.local/share/gem/gems/some-gem-1.0.0/lib/some_extension.bundle
Would delete /Users/hsbt/.local/share/gem/gems/another-gem-2.1.0/lib/another.bundle
...
```

**Aggressive mode:**
```bash
$ gem sweep --aggressive
Delete /Users/hsbt/.local/share/gem/gems/some-gem-1.0.0/lib/some_extension.bundle
Delete /Users/hsbt/.local/share/gem/gems/some-gem-1.0.0/test/
Delete /Users/hsbt/.local/share/gem/gems/some-gem-1.0.0/spec/
Delete /Users/hsbt/.local/share/gem/gems/another-gem-2.1.0/lib/another.bundle
Delete /Users/hsbt/.local/share/gem/gems/another-gem-2.1.0/features/
...
```

## Installation

```bash
$ gem install gem-sweep
```

## Development

After checking out the repo, run `bundle install` to install dependencies.

To build the gem, run:
```bash
$ bundle exec rake build
```

To install locally for testing:
```bash
$ bundle exec rake install
```

## Background

RubyGems will install native extension files into the following paths:

```
$GEM_HOME/gems/extensions/$arch-$platform-$version/$rubyversion/foo-x.y.z
$GEM_HOME/gems/foo-x.y.z/lib
```

The native extension files in `$GEM_HOME/gems/foo-x.y.z/lib` directory is harmful for us. Because this directory couldn't handle architecture, platform and ruby version. So, We should use native extension files in `$GEM_HOME/gems/extensions/$arch-$platform-$version/$rubyversion/foo-x.y.z` directory, not `$GEM_HOME/gems/foo-x.y.z/lib` directory.

## Safety

This tool is designed to be safe:

- It only removes native extension files (`.bundle`, `.so`, `.dll` files) from gem lib directories
- It preserves files in versioned directories (like `2.7/`, `3.0/`) to avoid breaking gems like google-protobuf and nokogiri
- In aggressive mode, it only removes commonly known development directories (`test/`, `spec/`, `features/`, `tmp/`)
- Handles permission errors gracefully by skipping inaccessible files

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
