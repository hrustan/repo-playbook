#!/usr/bin/env python3
"""Fail if a relative markdown link points at a file that does not exist.

Usage: check-links.py PATH [PATH...]   (markdown files, or directories to walk)

External links (anything with a scheme) and bare #anchors are ignored, and so
is anything inside a fenced code block or inline code. Standard library only.
"""

import pathlib
import re
import sys

LINK = re.compile(r"\[[^\]]*\]\(([^)\s]+)(?:\s+\"[^\"]*\")?\)")
SKIP_DIRS = {".git", "node_modules", ".venv"}


def link_targets(path: pathlib.Path):
    in_fence = False
    for number, line in enumerate(path.read_text(encoding="utf-8").splitlines(), 1):
        if line.lstrip().startswith("```"):
            in_fence = not in_fence
            continue
        if in_fence:
            continue
        for match in LINK.finditer(re.sub(r"`[^`]*`", "", line)):
            yield number, match.group(1)


def main(argv: list[str]) -> int:
    files: list[pathlib.Path] = []
    for arg in argv:
        path = pathlib.Path(arg)
        files += sorted(path.rglob("*.md")) if path.is_dir() else [path]
    files = [f for f in files if not SKIP_DIRS.intersection(f.parts)]

    broken = 0
    for file in files:
        for number, target in link_targets(file):
            if re.match(r"[a-z][a-z0-9+.-]*:", target) or target.startswith("#"):
                continue
            relative = target.split("#", 1)[0]
            if relative and not (file.parent / relative).exists():
                print(f"{file}:{number}: broken link -> {target}")
                broken += 1
    print(f"checked {len(files)} files, {broken} broken links")
    return 1 if broken else 0


if __name__ == "__main__":
    sys.exit(main(sys.argv[1:]))
