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
