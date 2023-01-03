# Changelog

<!-- markdownlint-disable MD024 -->

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [2.2.0] - 2023-01-02

### Added

- `remote_port` allows consumers to override the remote IAP tunnel endpoint exposed
  by the `forward-proxy` container on the bastion. Default value is 8888 for
  backward compatibility.
- `local_port` can be used to influence the generated output value `tunnel_command`
  that defines a `gcloud` operation to start an IAP tunnel that forwards connections
  made to localhost:local_port through the tunnel. Default value is 8888 for
  backward compatibility.

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

[2.2.0]: https://github.com/memes/terraform-google-private-bastion/compare/v2.1.0...v2.2.0
[2.1.0]: https://github.com/memes/terraform-google-private-bastion/compare/v2.0.2...v2.1.0
[2.0.2]: https://github.com/memes/terraform-google-private-bastion/compare/v2.0.1...v2.0.2
[2.0.1]: https://github.com/memes/terraform-google-private-bastion/compare/v2.0.0...v2.0.1
[2.0.0]: https://github.com/memes/terraform-google-private-bastion/compare/v1.0.0...v2.0.0
[1.0.0]: https://github.com/memes/terraform-google-private-bastion/releases/tag/v1.0.0
