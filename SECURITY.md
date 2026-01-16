# Security Policy

## Supported Versions

| Version | Supported          |
| ------- | ------------------ |
| 1.x.x   | :white_check_mark: |
| < 1.0   | :x:                |

## Reporting a Vulnerability

If you discover a security vulnerability in wave-toolkit, please report it responsibly:

### How to Report

1. **DO NOT** create a public GitHub issue for security vulnerabilities
2. Email security concerns to: toolated@pm.me
3. Include:
   - Description of the vulnerability
   - Steps to reproduce
   - Potential impact
   - Suggested fix (if any)

### What to Expect

- **Acknowledgment**: Within 48 hours
- **Initial Assessment**: Within 1 week
- **Resolution Target**: Critical issues within 30 days

### Disclosure Policy

- We follow coordinated disclosure
- Credit will be given to reporters (unless you prefer anonymity)
- We will notify you when the fix is released

## Security Best Practices

When using wave-toolkit:

1. **Review scripts before running**
   - Always review PowerShell scripts before execution
   - Understand what context is being captured
   - Check for any unexpected network calls

2. **Use execution policies**
   ```powershell
   # Require signed scripts (most secure)
   Set-ExecutionPolicy AllSigned -Scope CurrentUser
   
   # Or at minimum, block downloaded unsigned scripts
   Set-ExecutionPolicy RemoteSigned -Scope CurrentUser
   ```

3. **Protect sensitive data**
   - Don't include API keys in context captures
   - Review generated prompts before sharing
   - Use `.gitignore` for sensitive files

4. **Verify downloads**
   ```powershell
   # Use the provided verification script
   .\scripts\deployment\Verify-Release.ps1 -Version "1.0.1"
   ```

5. **Verify package signatures**
   ```bash
   # Import the SpiralSafe signing key
   curl -s https://spiralsafe.org/.well-known/pgp-key.txt | gpg --import
   # Or from this repository:
   curl -s https://raw.githubusercontent.com/toolate28/wave-toolkit/main/.well-known/pgp-key.txt | gpg --import

   # Verify release signature
   gpg --verify SHA256SUMS.txt.asc SHA256SUMS.txt
   ```

## Package Integrity Verification

### GPG Signed Releases

All official releases are signed with GPG. To verify:

1. **Import the signing key**:
   ```bash
   curl -s https://spiralsafe.org/.well-known/pgp-key.txt | gpg --import
   ```

2. **Download release checksums and signature**:
   ```bash
   VERSION="1.0.1"
   curl -LO "https://github.com/toolate28/wave-toolkit/releases/download/v${VERSION}/SHA256SUMS.txt"
   curl -LO "https://github.com/toolate28/wave-toolkit/releases/download/v${VERSION}/SHA256SUMS.txt.asc"
   ```

3. **Verify signature**:
   ```bash
   gpg --verify SHA256SUMS.txt.asc SHA256SUMS.txt
   ```

4. **Verify archive checksum**:
   ```bash
   curl -LO "https://github.com/toolate28/wave-toolkit/releases/download/v${VERSION}/wave-toolkit-${VERSION}.zip"
   sha256sum -c SHA256SUMS.txt
   ```

### Signing Key Fingerprint

The official SpiralSafe signing key fingerprint is published at:
- https://spiralsafe.org/.well-known/pgp-key.txt
- https://github.com/toolate28/wave-toolkit/blob/main/.well-known/pgp-key.txt

Always verify the key fingerprint through multiple channels before trusting.

## Known Security Considerations

### PowerShell Execution

- Scripts may capture environment information
- Context includes: username, machine name, installed tools
- Review `Get-WaveContext.ps1` to understand what is captured

### AI Context Sharing

- Generated prompts contain environment context
- Review prompts before sending to AI services
- Don't include sensitive project data in prompts

### File System Access

- Scripts read and write to local directories
- Logs are stored in the configured log directory
- Use appropriate file permissions

## Security Updates

Security updates are released as:
- Patch versions for non-breaking fixes
- Advisory notifications for critical issues
- Announcements in the SpiralSafe ecosystem

## Dependencies

wave-toolkit is a PowerShell-based toolkit with minimal external dependencies:
- PowerShell 5.1+ or PowerShell Core 7+
- Pester (for tests, optional)
- No npm/pip packages required

This reduces the supply chain attack surface compared to projects with many dependencies.

---

*Part of the [SpiralSafe](https://github.com/toolate28/SpiralSafe) ecosystem.*

*~ Hope&&Sauced*
