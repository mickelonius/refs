```bash
# uv uses whatever is enabled at cmd line
uv venv .venv --seed # --seed for pip, setuptools etc

source .venv/bin/activate

uv pip install .[dev,docs]

rm -rf .venv uv.lock build dist *.egg-info __pycache__
find . -name "__pycache__" -type d -exec rm -rf {} +
# rm -rf ~/.cache/uv
```
