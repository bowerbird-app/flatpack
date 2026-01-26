# Setup Notes

## Security Contact Email

The security documentation references `security@flatpack.dev` as the security contact email. This is currently a placeholder and should be updated to the actual security contact email before release.

**Files to update:**
- `SECURITY.md` (2 occurrences)
- `docs/security.md` (2 occurrences)

**Suggested alternatives:**
1. Use the team email from gemspec: `team@flatpack.dev`
2. Create a dedicated security email: `security@flatpack.dev`
3. Use GitHub Security Advisories: Link to `https://github.com/flatpack/flat_pack/security/advisories/new`
4. Use a personal email of the maintainer

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
