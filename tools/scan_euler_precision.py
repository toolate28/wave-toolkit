#!/usr/bin/env python3
"""
Ecosystem Euler's Number Precision Scanner

Scans SpiralSafe ecosystem repositories for hardcoded Euler's number
approximations (e.g., 2.718, 2.71828) that should use math.exp() or math.e.

Usage:
    python3 tools/scan_euler_precision.py
    python3 tools/scan_euler_precision.py --verbose
"""

import os
import re
import subprocess
import sys
from pathlib import Path
from typing import List, Tuple, Dict

# Repositories to scan (relative to user's home directory)
REPOS = [
    "SpiralSafe-FromGitHub",
    "repos/ClaudeNPC-Server-Suite",
    "repos/SpiralSafe",
    "quantum-redstone",
    "wave-toolkit",
]

# Patterns to detect hardcoded Euler's number
PATTERNS = {
    'python_pow': r'pow\s*\(\s*2\.71[0-9]*\s*,',
    'python_exp': r'(?<![a-zA-Z_])2\.71[0-9]*\s*\*\*',
    'js_java_pow': r'Math\.pow\s*\(\s*2\.71[0-9]*',
    'direct_const': r'(?<![a-zA-Z_])e\s*=\s*2\.71[0-9]*',
}

# File extensions to scan
EXTENSIONS = ['.py', '.js', '.java', '.ts', '.jsx', '.tsx', '.c', '.cpp', '.go', '.rs']


class Finding:
    """Represents a potential precision issue."""
    
    def __init__(self, repo: str, file_path: str, line_num: int, line: str, pattern_name: str):
        self.repo = repo
        self.file_path = file_path
        self.line_num = line_num
        self.line = line.strip()
        self.pattern_name = pattern_name
    
    def __str__(self):
        return f"{self.repo}/{self.file_path}:{self.line_num} [{self.pattern_name}]\n    {self.line}"


def scan_file(file_path: Path, patterns: Dict[str, str]) -> List[Tuple[int, str, str]]:
    """
    Scan a single file for hardcoded Euler approximations.
    
    Returns:
        List of (line_number, line_content, pattern_name) tuples
    """
    findings = []
    try:
        with open(file_path, 'r', encoding='utf-8', errors='ignore') as f:
            for line_num, line in enumerate(f, 1):
                for pattern_name, pattern in patterns.items():
                    if re.search(pattern, line):
                        findings.append((line_num, line, pattern_name))
    except Exception as e:
        if '--verbose' in sys.argv:
            print(f"  Warning: Could not scan {file_path}: {e}", file=sys.stderr)
    
    return findings


def scan_repo(repo_path: str, patterns: Dict[str, str], verbose: bool = False) -> List[Finding]:
    """
    Recursively scan a repository for hardcoded Euler approximations.
    
    Args:
        repo_path: Path to repository relative to home directory
        patterns: Dictionary of pattern names to regex patterns
        verbose: Print progress information
    
    Returns:
        List of Finding objects
    """
    base = Path.home() / repo_path
    if not base.exists():
        if verbose:
            print(f"  ⚠️  Repository not found: {repo_path}")
        return []
    
    findings = []
    file_count = 0
    
    if verbose:
        print(f"  Scanning {repo_path}...")
    
    for ext in EXTENSIONS:
        for file_path in base.rglob(f"*{ext}"):
            # Skip common directories
            if any(skip in file_path.parts for skip in ['.git', 'node_modules', 'target', 'build', '__pycache__']):
                continue
            
            file_count += 1
            file_findings = scan_file(file_path, patterns)
            
            for line_num, line, pattern_name in file_findings:
                rel_path = file_path.relative_to(base)
                findings.append(Finding(repo_path, str(rel_path), line_num, line, pattern_name))
    
    if verbose:
        print(f"    Scanned {file_count} files, found {len(findings)} issues")
    
    return findings


def print_report(all_findings: List[Finding], verbose: bool = False):
    """Print formatted report of findings."""
    
    print("\n" + "=" * 70)
    print("🔍 EULER'S NUMBER PRECISION SCAN RESULTS")
    print("=" * 70)
    
    if not all_findings:
        print("\n✅ No hardcoded Euler approximations found!")
        print("   All scanned repositories using proper math.exp() or math.e")
        return
    
    print(f"\n❌ FOUND {len(all_findings)} POTENTIAL PRECISION ISSUES:\n")
    
    # Group by repository
    by_repo: Dict[str, List[Finding]] = {}
    for finding in all_findings:
        if finding.repo not in by_repo:
            by_repo[finding.repo] = []
        by_repo[finding.repo].append(finding)
    
    # Print findings by repository
    for repo, findings in sorted(by_repo.items()):
        print(f"\n📂 {repo} ({len(findings)} issues)")
        print("─" * 70)
        for finding in findings:
            print(f"  {finding}")
    
    # Print summary
    print("\n" + "=" * 70)
    print("📊 SUMMARY")
    print("=" * 70)
    print(f"Repositories scanned: {len(REPOS)}")
    print(f"Repositories with issues: {len(by_repo)}")
    print(f"Total issues found: {len(all_findings)}")
    
    # Priority recommendations
    print("\n🎯 RECOMMENDED ACTIONS:")
    print("1. Review each finding to confirm it's a precision issue")
    print("2. Replace 'pow(2.718, x)' with 'math.exp(x)' (Python)")
    print("3. Replace 'Math.pow(2.718, x)' with 'Math.exp(x)' (JS/Java)")
    print("4. Replace hardcoded constants with math.e / Math.E")
    print("5. Refer to: wave-toolkit/examples/euler_number_usage.py")


def main():
    """Main entry point."""
    verbose = '--verbose' in sys.argv or '-v' in sys.argv
    
    print("🌊 Wave Toolkit - Ecosystem Precision Scanner")
    print("Scanning for hardcoded Euler's number approximations...")
    
    if verbose:
        print(f"\nRepositories to scan: {', '.join(REPOS)}")
        print(f"File types: {', '.join(EXTENSIONS)}")
        print(f"Patterns: {len(PATTERNS)}\n")
    
    all_findings = []
    for repo in REPOS:
        findings = scan_repo(repo, PATTERNS, verbose)
        all_findings.extend(findings)
    
    print_report(all_findings, verbose)
    
    # Exit code: 0 if no issues, 1 if issues found
    sys.exit(1 if all_findings else 0)


if __name__ == "__main__":
    main()
