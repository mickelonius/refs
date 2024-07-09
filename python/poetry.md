## Existing requirements.txt file with no pins:
Generate `migrate_requirments.py`:
```python
import subprocess

def add_dependencies_from_requirements(file_path='requirements.txt'):
    with open(file_path, 'r') as file:
        for line in file:
            # Skip comments and empty lines
            if line.startswith('#') or not line.strip():
                continue
            # Extract package name (no specific version handling required)
            package = line.strip()
            try:
                subprocess.run(['poetry', 'add', package], check=True)
            except subprocess.CalledProcessError as e:
                print(f"Failed to add {package}: {e}")

# Call the function to add dependencies
add_dependencies_from_requirements()
```

Then, initialize poetry and use `subprocess` to run `poetry add` in a loop:
````bash
poetry init --no-interaction
python migrate_requirements.py
poetry install
```