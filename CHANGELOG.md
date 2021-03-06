# Changelog

<!-- markdownlint-disable MD024 -->

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [2.0.2] - 2022-06-11

### Added

- `self_link` output of the bastion instance

### Changed

### Removed

## [2.0.1] - 2022-05-17

### Added

- `ip_address` output to retrieve the private IP address of the bastion instance

### Changed

### Removed

## [2.0.0] - 2022-05-05

This release updates the wrapped Google Bastion module to track v5.x, and includes
a breaking variable change from that module.

### Added

### Changed

- mirror upstream bastion module variable name change; `ephemeral_ip` is now
  `external_ip`
- pin `forward-proxy` base container to `alpine:3.15.4`

### Removed

## [1.0.0] - 2022-02-16

Initial public release of module.

### Added

### Changed

### Removed

[2.0.2]: https://github.com/memes/terraform-google-private-bastion/compare/v2.0.1...v2.0.2
[2.0.1]: https://github.com/memes/terraform-google-private-bastion/compare/v2.0.0...v2.0.1
[2.0.0]: https://github.com/memes/terraform-google-private-bastion/compare/v1.0.0...v2.0.0
[1.0.0]: https://github.com/memes/terraform-google-private-bastion/releases/tag/v1.0.0
