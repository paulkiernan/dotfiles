---
name: lightsail-safe-bootstrap
description: "Provision or remediate an Ubuntu Lightsail host with restricted SSH, AWS-witnessed host-key trust, and verifiable bootstrap behavior."
---

# Safe Ubuntu Lightsail bootstrap

## Before creating resources

- Verify authenticated AWS access and query the current bundle price/specifications against the user's authorized spend. Do not assume a bundle ID has an immutable price.
- Preserve OpenTofu state and dedicated SSH keys securely. Do not print credentials or copy AWS credentials onto a collector that only consumes public feeds.
- Determine the actual operator and automation egress addresses separately. Keep SSH limited to the necessary /32s; do not open metrics publicly.

## Bootstrap behavior

- Prefer POSIX sh for Lightsail user-data. In an observed Ubuntu 24.04 deployment, AWS prepended a `/bin/sh` wrapper; a later `#!/bin/bash` was just a comment and `pipefail` aborted the script.
- Diagnose failures from the actual cloud-init output/generated script. Apply missed hardening explicitly; retain original failure logs rather than claiming a clean initial boot.
- Minimal images need not contain `/etc/sysusers.d`. GNU `install -D -m 0644 -o root -g root SOURCE DEST` creates missing leading destination directories. Verify this in an isolated temp path, never by moving a live system directory.
- Treat existing-instance user-data as create-time configuration. Do not replace a data-bearing VM merely to update bootstrap text; use the documented existing-host remediation path. Retain destruction protection and explain lifecycle ignores rather than falsifying state.

## Establish SSH host identity

- Do not treat unauthenticated `ssh-keyscan` output as a trusted pin.
- Query only host-key fields from authenticated `GetInstanceAccessDetails`; the full response also contains sensitive client access material.
- If `accessDetails.hostKeys` remains empty behind /32-only SSH rules, temporarily add the documented `lightsail-connect` CIDR-list alias to TCP 22 while retaining the original addresses. Retry the API; use a dedicated authenticated console Connect page if necessary. Interactive browser SSH was not needed in the observed successful run.
- Build a dedicated known_hosts file from the AWS-witnessed keys and compare fingerprints. Keep the witness timestamp. These are AWS-witnessed keys, not hardware attestation; `certKey` is a client certificate, not a host-CA anchor.
- Immediately remove the temporary alias and verify the final firewall. Use strict host-key checking, a dedicated identity, and no agent forwarding for subsequent SSH.

## Prove the deployed path

- Check effective SSH configuration, time synchronization, service health, and actual application output.
- For a read-only rsync account, exercise both rejection of arbitrary commands and rejection of uploads. Do not weaken the server to accommodate an incompatible client.
- Verify a completed scheduled transfer and integrity of its real output, not merely an enabled schedule. Distinguish configured rotation from an actually observed seal.
- Check telemetry ingestion separately from exporter process health. An active exporter can still receive quota errors; do not claim working alerts without delivery/provisioning evidence or buy capacity without authorization.
- Remove only owned staging/test artifacts; retain production data, state, private keys, and trusted pins.

## References

- https://docs.aws.amazon.com/lightsail/2016-11-28/api-reference/API_PortInfo.html
- https://docs.aws.amazon.com/lightsail/2016-11-28/api-reference/API_HostKeyAttributes.html
