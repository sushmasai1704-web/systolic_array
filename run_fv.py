#!/usr/bin/env python3
"""Automates sby runs and parses pass/fail results."""
import subprocess, re, sys, json
from datetime import datetime

def run_sby(sby_file):
    result = subprocess.run(
        ["sby", "-f", sby_file],
        capture_output=True, text=True
    )
    output = result.stdout + result.stderr
    status = "PASS" if "DONE (PASS" in output else "FAIL"
    failed = re.findall(r'failed assertion (\S+) at (\S+) in step (\d+)', output)
    return {
        "file": sby_file,
        "status": status,
        "returncode": result.returncode,
        "failed_assertions": failed,
        "timestamp": datetime.now().isoformat()
    }

if __name__ == "__main__":
    sby_file = sys.argv[1] if len(sys.argv) > 1 else "pe.sby"
    report = run_sby(sby_file)
    print(json.dumps(report, indent=2))
    print(f"\n{'='*40}")
    print(f"STATUS: {report['status']}")
    if report['failed_assertions']:
        print("FAILED ASSERTIONS:")
        for a in report['failed_assertions']:
            print(f"  {a[0]} at {a[1]} step {a[2]}")
