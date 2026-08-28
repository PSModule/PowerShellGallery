# PowerShellGallery

PowerShellGallery is a PowerShell module for interacting with the [PowerShell Gallery](https://www.powershellgallery.com).

Version 1 focuses on two publisher-oriented workflows:

- **Discovery** — read package and API metadata from the public OData v2 endpoint.
- **Listing management** — list and unlist package versions you own, using gallery API credentials.

## Installation

Install the module from the PowerShell Gallery when a published release is available:

```powershell
Install-PSResource -Name PowerShellGallery -TrustRepository
```

## Quick start

```powershell
# Read gallery API metadata
Get-PowerShellGalleryAPI

# Search for packages
Find-PowerShellGalleryPackage -Name 'Pester' -First 5

# Get a specific package
Get-PowerShellGalleryPackage -Name 'Pester' -Version '5.5.0'
```

## Documentation

- [v1 Specification](specs/v1.md) — functional specification for the initial release.

## Contributing

See `CONTRIBUTING.md` and `AGENTS.md` in the repository root.
