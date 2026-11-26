"""Check that the Chinese installation guide installs this module release."""
import json
import re
from pathlib import Path


def verify(root):
    manifest = (root / "moon.mod").read_text(encoding="utf-8")
    readme = (root / "README.md").read_text(encoding="utf-8")
    module = re.search(r'^name\s*=\s*"([^"\n]+)"', manifest, re.M).group(1)
    version = re.search(r'^version\s*=\s*"([^"\n]+)"', manifest, re.M).group(1)
    installed = re.findall(r"^moon add " + re.escape(module) + r"@([^\s]+)$", readme, re.M)
    if installed != [version]:
        raise ValueError("README install version differs from module release")
    if "版本 `" + version + "`" not in readme:
        raise ValueError("README release description differs from manifest")
    return {"module": module, "version": version, "readme_version_consistent": True}


if __name__ == "__main__":
    print(json.dumps(verify(Path(__file__).resolve().parents[1])))
