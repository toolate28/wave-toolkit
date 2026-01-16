# Release Process

This document describes the release process for wave-toolkit, including versioning, GPG signing, and SpiralSafe synchronization.

## Overview

Releases follow [Semantic Versioning](https://semver.org/):
- **MAJOR**: Breaking changes
- **MINOR**: New features (backward compatible)
- **PATCH**: Bug fixes (backward compatible)

## Automated Release Workflow

The release process is automated via GitHub Actions. A release is triggered by:

1. **Tag Push**: Pushing a tag matching `v*` (e.g., `v1.0.1`)
2. **Manual Dispatch**: Using the GitHub Actions UI to trigger a release

### Triggering a Release

#### Option 1: Tag Push

```bash
# Create and push a tag
git tag -a v1.0.1 -m "Release v1.0.1"
git push origin v1.0.1
```

#### Option 2: Manual Dispatch

1. Go to **Actions** → **Release** workflow
2. Click **Run workflow**
3. Enter the version number (e.g., `1.0.1`)
4. Optionally mark as pre-release
5. Click **Run workflow**

## Release Pipeline

The release workflow consists of the following jobs:

```
┌──────────────┐
│   Validate   │  ← Run Pester tests, determine version
└──────┬───────┘
       │
       ▼
┌──────────────┐
│    Build     │  ← Create zip/tar.gz archives, generate checksums
└──────┬───────┘
       │
       ▼
┌──────────────┐
│     Sign     │  ← GPG sign artifacts (if keys configured)
└──────┬───────┘
       │
       ▼
┌──────────────┐
│   Release    │  ← Create GitHub Release with artifacts
└──────┬───────┘
       │
       ▼
┌──────────────┐
│ Notify Sync  │  ← Notify SpiralSafe ecosystem
└──────────────┘
```

## GPG Signing

### Why GPG Signing?

GPG signatures provide:
- **Authenticity**: Proof that releases come from the official maintainers
- **Integrity**: Detection of any tampering with release artifacts
- **Trust**: Verification through the web of trust

### Setting Up GPG Signing

#### 1. Generate a GPG Key

```bash
# Generate a new key
gpg --full-generate-key

# Select:
# - RSA and RSA (default)
# - 4096 bits
# - Key does not expire (or set expiry)
# - Use: SpiralSafe Release Signing <release@spiralsafe.org>
```

#### 2. Export Keys

```bash
# Get the key ID
gpg --list-secret-keys --keyid-format LONG

# Export private key (keep this safe!)
gpg --armor --export-secret-keys YOUR_KEY_ID > private-key.asc

# Export public key (for verification)
gpg --armor --export YOUR_KEY_ID > public-key.asc
```

#### 3. Configure GitHub Secrets

Add these secrets to the repository:

| Secret | Description |
|--------|-------------|
| `GPG_PRIVATE_KEY` | Contents of `private-key.asc` |
| `GPG_PASSPHRASE` | Passphrase for the GPG key |
| `GPG_KEY_ID` | Key ID (e.g., `ABCD1234EFGH5678`) |
| `SPIRALSAFE_API_TOKEN` | SpiralSafe API token for sync notifications |

#### 4. Publish Public Key

The public key should be published to:
- Repository `.well-known/pgp-key.txt`
- https://spiralsafe.org/.well-known/pgp-key.txt
- Key servers (optional): `gpg --keyserver keyserver.ubuntu.com --send-keys YOUR_KEY_ID`

### Verifying Releases

Users can verify release signatures using PowerShell:

```powershell
# Use the provided verification script
.\scripts\deployment\Verify-Release.ps1 -Version "1.0.1"
```

Or manually with bash/WSL:

```bash
# 1. Import the SpiralSafe signing key
curl -s https://spiralsafe.org/.well-known/pgp-key.txt | gpg --import
# Or from this repository:
curl -s https://raw.githubusercontent.com/toolate28/wave-toolkit/main/.well-known/pgp-key.txt | gpg --import

# 2. Download the release artifacts
VERSION="1.0.1"
curl -LO "https://github.com/toolate28/wave-toolkit/releases/download/v${VERSION}/SHA256SUMS.txt"
curl -LO "https://github.com/toolate28/wave-toolkit/releases/download/v${VERSION}/SHA256SUMS.txt.asc"

# 3. Verify the signature
gpg --verify SHA256SUMS.txt.asc SHA256SUMS.txt

# 4. Verify the archive checksum
curl -LO "https://github.com/toolate28/wave-toolkit/releases/download/v${VERSION}/wave-toolkit-${VERSION}.zip"
sha256sum -c SHA256SUMS.txt
```

## Package Integrity

### Checksums

Each release includes:
- `SHA256SUMS.txt` - SHA-256 checksums of all artifacts
- `SHA512SUMS.txt` - SHA-512 checksums of all artifacts

### Release Archives

Releases are distributed as:
- `wave-toolkit-VERSION.zip` - For Windows/PowerShell users
- `wave-toolkit-VERSION.tar.gz` - For Unix/Linux users

## SpiralSafe Synchronization

Releases are automatically synced with the SpiralSafe ecosystem:

1. **Notification**: The release workflow notifies the SpiralSafe API
2. **Registry Update**: SpiralSafe registry is updated with the new version
3. **Documentation Sync**: Release notes are synchronized to SpiralSafe docs

### Manual Sync

If automatic sync fails, manually update:

1. Announce in the SpiralSafe Discord
2. Update cross-references in related repositories

## Release Checklist

Before releasing:

- [ ] All tests pass (`Invoke-Pester ./tests`)
- [ ] README is up to date
- [ ] Version number updated in README badges
- [ ] No security vulnerabilities in scripts
- [ ] Changelog updated (if maintaining one)

After releasing:

- [ ] Verify GitHub Release created with artifacts
- [ ] Verify checksums are correct
- [ ] Verify GPG signatures (if enabled)
- [ ] Test installation from release archive
- [ ] Update SpiralSafe ecosystem docs (if needed)

## Troubleshooting

### Release Failed

1. Check the GitHub Actions logs for the specific error
2. Common issues:
   - Missing secrets (GPG keys)
   - Test failures
   - Archive creation errors

### GPG Signing Failed

1. Verify GPG_PRIVATE_KEY is correctly formatted
2. Check passphrase is correct
3. Ensure key hasn't expired

## Security Considerations

- GPG private keys are stored as GitHub Secrets (encrypted at rest)
- Release workflow only triggers on tags or manual dispatch
- All releases are auditable via GitHub Actions logs

---

*See [SECURITY.md](../SECURITY.md) for security reporting procedures.*
