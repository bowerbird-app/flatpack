# Setup Notes

## Development Dependencies

The following security gems were added to the gemspec:
- `brakeman (~> 6.0)` - Static security analysis
- `bundler-audit (~> 0.9)` - Dependency vulnerability scanning

To install these gems for development:
```bash
bundle install
```

Note: These gems are listed as development dependencies, so they won't be installed when users add FlatPack to their applications.

## GitHub Actions

### Security Workflow

The `.github/workflows/security.yml` workflow requires:
1. GitHub Actions to be enabled for the repository
2. The workflow will run automatically on:
   - Every push to main branch
   - Every pull request to main branch
   - Weekly on Mondays at 00:00 UTC

The workflow includes:
- Brakeman security scanner
- Bundler-audit for dependency vulnerabilities
- Dependency Review for PRs

### Test Workflow

The `.github/workflows/test.yml` workflow runs comprehensive tests:
1. **Rails Tests**: Runs the full test suite with `bundle exec rake test`
2. **Dummy App Tests**: Validates the dummy application can:
   - Set up the database
   - Build Tailwind CSS assets
   - Precompile assets
   - Successfully boot
3. **Lint**: Runs RuboCop for code quality checks

The workflow runs automatically on:
- Every push to main branch
- Every pull request to main branch
