# Contributing to FileConverter

Thank you for your interest in contributing to FileConverter! This document provides guidelines for contributing.

---

## Code of Conduct

- Be respectful and inclusive
- Welcome diverse perspectives
- Focus on the code, not the person
- Help others learn and grow

---

## Getting Started

1. **Fork the repository** on GitHub
2. **Clone your fork locally:**
   ```bash
   git clone https://github.com/YOUR-USERNAME/FileConverter.git
   cd FileConverter
   ```

3. **Add upstream remote:**
   ```bash
   git remote add upstream https://github.com/Aman-Gupta710/FileConverter.git
   ```

4. **Install dependencies:**
   ```bash
   brew install ffmpeg cwebp exiftool ghostscript
   ```

---

## Development Workflow

### 1. Create a Feature Branch

```bash
git checkout -b feature/your-feature-name
```

Branch naming:
- `feature/` - New features
- `fix/` - Bug fixes
- `docs/` - Documentation
- `refactor/` - Code improvements

### 2. Make Your Changes

**Code Style:**
- Follow Swift conventions
- Use descriptive names
- Keep functions small
- Add comments for complex logic
- Use async/await for I/O

**Example:**
```swift
public func convert(job: inout ConversionJob) async throws {
    // Clear, descriptive implementation
    guard fileExists(at: job.inputURL) else {
        throw ConversionError.fileNotFound
    }
    // ... rest of implementation
}
```

### 3. Test Your Changes

```bash
# Build
swift build -c release

# Test conversion
.build/release/fileconverter convert sample.jpg sample.png

# Verify output exists and is correct
file sample.png
```

### 4. Commit Your Changes

```bash
git add .
git commit -m "feat(module): description of changes"
```

**Commit message format:**
```
<type>(<scope>): <subject>

<body>

<footer>
```

**Types:**
- `feat` - New feature
- `fix` - Bug fix
- `docs` - Documentation
- `style` - Code style (no functional change)
- `refactor` - Code refactoring
- `perf` - Performance improvement
- `test` - Adding/updating tests
- `chore` - Maintenance tasks

**Example:**
```
feat(converter): add HEIF image format support

- Implement HEIF to JPEG converter
- Add heif input/output formats to config
- Test with sample HEIF files

Closes #123
```

### 5. Keep Your Branch Updated

```bash
git fetch upstream
git rebase upstream/main
```

### 6. Push and Create Pull Request

```bash
git push origin feature/your-feature-name
```

Then open a PR on GitHub with:
- Clear title
- Description of changes
- How to test
- Any breaking changes
- Closes #(issue number)

---

## Pull Request Guidelines

### Before Submitting

- [ ] Branch is up-to-date with main
- [ ] Code compiles without warnings
- [ ] Manual testing completed
- [ ] Commit messages are clear
- [ ] No unrelated changes

### PR Description Template

```markdown
## Description
Brief description of changes

## Type of Change
- [ ] Bug fix
- [ ] New feature
- [ ] Breaking change
- [ ] Documentation update

## How to Test
Steps to verify the changes:
1. 
2. 
3. 

## Testing Evidence
- Test file: sample.jpg
- Input format: JPEG
- Output format: PNG
- Result: ✅ Successful

## Screenshots (if applicable)
*Add screenshots or test output here*

## Breaking Changes
- None / List breaking changes

## Closes
Closes #123
```

---

## Testing

### Manual Testing

```bash
# Build
swift build -c release

# Test conversion
.build/release/fileconverter convert input.jpg output.png

# Verify
file output.png
ls -la output.png
```

### Test Cases

When adding a feature, test:
- ✅ Valid input files
- ✅ Invalid file formats
- ✅ Missing files
- ✅ Permission errors
- ✅ Large files
- ✅ Special characters in filenames

---

## Adding New Converters

### Step 1: Add to Configuration

Edit `Core/Resources/converters.yaml`:

```yaml
- id: "format-x-to-y"
  name: "Format X → Format Y"
  category: "category"
  inputFormats: ["x"]
  outputFormats: ["y"]
  tool: "tool-name"
  command: "tool-name {input} -o {output}"
  options:
    - name: "quality"
      type: "slider"
      min: 0
      max: 100
      default: 80
```

### Step 2: Test

```bash
# Rebuild
swift build -c release

# Test conversion
.build/release/fileconverter convert sample.x sample.y
```

### Step 3: Verify

```bash
# Check output format
file sample.y

# Check file properties
ls -la sample.y
```

### Step 4: Update Docs

- Update [SETUP.md](SETUP.md)
- Add example to [GETTING_STARTED.md](GETTING_STARTED.md)
- Update README.md if applicable

---

## Commit Message Examples

### Feature
```
feat(cli): add verbose output option

- Add --verbose flag to show detailed conversion info
- Display ffmpeg command being executed
- Help users debug conversion issues

Closes #42
```

### Bug Fix
```
fix(engine): handle files with spaces in names

- Properly escape input/output paths in commands
- Add quotes around file paths in shell commands
- Test with files like "my document.pdf"

Closes #51
```

### Documentation
```
docs: add batch processing examples

- Include shell script example
- Document conversion loops
- Add troubleshooting section
```

---

## Code Review Process

1. **Automated checks:**
   - Code compiles
   - No obvious errors
   - Basic linting

2. **Manual review:**
   - Code quality
   - Testing completeness
   - Documentation updates
   - Alignment with project goals

3. **Feedback:**
   - Request changes if needed
   - Suggest improvements
   - Discuss design decisions

4. **Approval:**
   - Merge when all checks pass
   - At least one approval
   - All conversations resolved

---

## Project Structure

```
FileConverter/
├── Core/
│   ├── Converter.swift           # Data models
│   ├── ConverterEngine.swift     # Conversion logic
│   ├── ConfigLoader.swift        # YAML config parsing
│   ├── ProcessManager.swift      # Process execution
│   ├── ToolManager.swift         # Tool detection
│   ├── JobQueue.swift            # Async job queue
│   └── Resources/
│       └── converters.yaml       # Converter definitions
├── CLI/
│   └── main.swift                # CLI entry point
├── FileConverter/                # GUI (WIP)
├── Package.swift                 # Swift manifest
├── README.md
├── SETUP.md
├── GETTING_STARTED.md
├── CONTRIBUTING.md               # This file
└── LICENSE
```

---

## Common Tasks

### Add a New Converter Format

1. Edit `Core/Resources/converters.yaml`
2. Test with `swift build -c release`
3. Update documentation
4. Commit with `feat(converter):`

### Fix a Bug

1. Create issue describing the bug
2. Create branch `fix/issue-description`
3. Fix the issue
4. Add test case
5. Commit with `fix:`

### Update Documentation

1. Edit the relevant `.md` file
2. Test links and formatting
3. Commit with `docs:`

### Improve Performance

1. Profile the code
2. Identify bottleneck
3. Optimize
4. Verify performance improvement
5. Commit with `perf:`

---

## Troubleshooting

### Build Fails
```bash
# Clean and rebuild
rm -rf .build
swift build -c release
```

### Tests Don't Run
```bash
# Ensure dependencies installed
brew install ffmpeg cwebp exiftool ghostscript

# Verify installation
ffmpeg -version
```

### Conversion Doesn't Work
```bash
# Check config file location
cat ~/.fileconverter/converters.yaml

# Verify tool installed
which ffmpeg

# Test directly
ffmpeg -i test.jpg test.png -y
```

---

## Questions?

- **Issues:** GitHub Issues
- **Discussions:** GitHub Discussions
- **Email:** Create an issue with your question

---

## License

By contributing, you agree your code will be licensed under the MIT License.

---

**Thank you for contributing to FileConverter! 🎉**

Your contributions make this project better for everyone.
