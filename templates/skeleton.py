#!/usr/bin/env python3
"""${1:Module description.}"""

from __future__ import annotations
import argparse
import sys


def parse_args() -> argparse.Namespace:
    p = argparse.ArgumentParser()
    # p.add_argument("--flag", action="store_true")
    return p.parse_args()


def main() -> int:
    args = parse_args()
    print("hello, world")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
