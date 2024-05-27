# Changelog

<!-- markdownlint-disable MD004 MD012 MD024 -->

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [3.0.1](https://github.com/memes/terraform-google-private-bastion/compare/v3.0.0...v3.0.1) (2024-05-27)


### Bug Fixes

* Update tinyproxy for CVE mitigation ([a1e362b](https://github.com/memes/terraform-google-private-bastion/commit/a1e362b2e2f55014379c4019eac113d7ef601e2e)), closes [#533](https://github.com/memes/terraform-google-private-bastion/issues/533)

## [3.0.0](https://github.com/memes/terraform-google-private-bastion/compare/v2.3.5...v3.0.0) (2024-03-15)


### ⚠ BREAKING CHANGES

* Remove Google Bastion module, provider >= 5

### Features

* Remove Google Bastion module, provider &gt;= 5 ([c02bcdb](https://github.com/memes/terraform-google-private-bastion/commit/c02bcdb6aa775471c5aad66c53bc8c5f78375393))


### Bug Fixes

* Updated forward_proxy to use alpine 3.19.1 ([2581c52](https://github.com/memes/terraform-google-private-bastion/commit/2581c52a34a5a1520df940b3ce9f40c764c3c0f3))

## [2.3.5](https://github.com/memes/terraform-google-private-bastion/compare/v2.3.4...v2.3.5) (2023-04-07)


### Bug Fixes

* Add service account output ([923f466](https://github.com/memes/terraform-google-private-bastion/commit/923f4668f3f048e350e0a95bfb5d26b90d2cca21))

## [2.3.4](https://github.com/memes/terraform-google-private-bastion/compare/v2.3.3...v2.3.4) (2023-04-07)


### Bug Fixes

* Add public IP address output ([80aa8a7](https://github.com/memes/terraform-google-private-bastion/commit/80aa8a747740261cb48534fd6f6441c64af4813c)), closes [#57](https://github.com/memes/terraform-google-private-bastion/issues/57)

## [2.3.3](https://github.com/memes/terraform-google-private-bastion/compare/v2.3.2...v2.3.3) (2023-02-12)


### Bug Fixes

* Always push containers if release triggered ([caf88d5](https://github.com/memes/terraform-google-private-bastion/commit/caf88d5e6fbed0384af856afff867036d608543b))

## [2.3.2](https://github.com/memes/terraform-google-private-bastion/compare/v2.3.1...v2.3.2) (2023-02-12)


### Bug Fixes

* Use release-please-action tag_name as tag ([9341803](https://github.com/memes/terraform-google-private-bastion/commit/9341803f911abaabaea810ec06679aad0cb5eb9c))

## [2.3.1](https://github.com/memes/terraform-google-private-bastion/compare/v2.3.0...v2.3.1) (2023-02-12)


### Bug Fixes

* Forward-proxy container build ([61ec312](https://github.com/memes/terraform-google-private-bastion/commit/61ec31268def32074e6dc95e280d6d2299c35e2e))
* Resolve broken Alpine package installation ([f741e0e](https://github.com/memes/terraform-google-private-bastion/commit/f741e0eef22525732e69c37b4d02c28634152335))

## [2.3.0](https://github.com/memes/terraform-google-private-bastion/compare/v2.2.1...v2.3.0) (2023-02-12)


### Features

* Add badges and Contributor Covenant ([db6ad72](https://github.com/memes/terraform-google-private-bastion/commit/db6ad72fad5c783d940b639166cf8ef8c68154e6))

## [2.2.1] - 2023-01-02

### Added

### Changed

- Updated `forward-proxy` container to use Alpine 3.17.0, and Tinyproxy 1.11.1-r2

### Removed

## [2.2.0] - 2023-01-02

### Added

- `remote_port` allows consumers to override the remote IAP tunnel endpoint exposed
  by the `forward-proxy` container on the bastion. Default value is 8888 for
  backward compatibility.
- `local_port` can be used to influence the generated output value `tunnel_command`
  that defines a `gcloud` operation to start an IAP tunnel that forwards connections
  made to localhost:local_port through the tunnel. Default value is 8888 for
  backward compatibility.

### Changed

### Removed

## [2.1.0] - 2022-11-19

### Added

### Changed

- `forward-proxy`container:  Upgraded to use Alpine 3.16.3 base OS
- `forward-proxy` container: Use June 2022 CA certificate bundle
- Terraform: Upgraded dependency on Google's `bastion-host` module to 5.1.0

### Removed

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

[2.2.1]: https://github.com/memes/terraform-google-private-bastion/compare/v2.2.0...v2.2.1
[2.2.0]: https://github.com/memes/terraform-google-private-bastion/compare/v2.1.0...v2.2.0
[2.1.0]: https://github.com/memes/terraform-google-private-bastion/compare/v2.0.2...v2.1.0
[2.0.2]: https://github.com/memes/terraform-google-private-bastion/compare/v2.0.1...v2.0.2
[2.0.1]: https://github.com/memes/terraform-google-private-bastion/compare/v2.0.0...v2.0.1
[2.0.0]: https://github.com/memes/terraform-google-private-bastion/compare/v1.0.0...v2.0.0
[1.0.0]: https://github.com/memes/terraform-google-private-bastion/releases/tag/v1.0.0
