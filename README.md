# Markdown Linter Script

A simple, no-dependency Bash script for checking Markdown (`.md`) files for two common
formatting issues:

1. **Lines exceeding a configurable maximum length (default: 88 characters)**

   * *Exception:* Markdown-style hyperlinks that span beyond the limit.

2. **Trailing whitespace on any line**

Useful as a lightweight linter in CI pipelines or pre-commit hooks.

---

## Features

* Recursively checks all `.md` files in the current directory.
* Ignores files inside specified directories (e.g., `.git`, `.venv`, `build`, `dist`).
* Skips overlong lines if the overflow is due to a valid Markdown
  hyperlink (`[text](url)`).
* Prints formatted error messages with color-coded line numbers and codes:

  * `E501` – Line too long
  * `W209` – Trailing whitespace

---

## Usage

```bash
./lint-md.sh
```

This script scans all Markdown files under the current directory, ignoring common build
and environment folders.

### Example Output

```text
./docs/README.md:12:89: E501 Line too long (102 > 88 characters)
./docs/README.md:19:35: W209 Trailing whitespace
```

## Configuration

You can adjust the following parameters at the top of the script:

```bash
MAX_LINE_LENGTH=88          # Max allowed characters per line
IGNORE_DIRS=".git .venv"    # Space-separated directories to exclude
```

## Exit Codes

* `0` – No issues found
* `1` – One or more formatting issues detected

This makes it suitable for automation (e.g., in CI/CD workflows or pre-commit hooks).

## Installation (Optional)

Place the script somewhere in your `PATH`, e.g., `/usr/local/bin/`:

```bash
chmod +x lint-md.sh
sudo mv lint-md.sh /usr/local/bin/mdlint
```

Then run it anywhere:

```bash
mdlint
```

---

## Known Limitations

* It only recognizes standard Markdown link syntax (`[text](url)`); raw URLs are not
  exempted.
* Non-Markdown files are not checked.
* No support for `.markdown` extension—only `.md`.

## License

This script is provided under the MIT License. Use it at your own discretion.
