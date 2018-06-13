<a name="header1"></a>
# sp_EasyButton
[![licence badge]][licence]
[![stars badge]][stars]
[![forks badge]][forks]
[![issues badge]][issues]

For when you just need an Easy Button. One-button server configuration to implement commonly-accepted best practices.

## Coverage
- Configuration 
  - `ARITHABORT`
  - Show Advanced Options
  - Backup Compression Default (2008R2+ v10.5)
  - Lightweight pooling
  - Priority boost
  - Remote admin connections
  - Cost threshold for parallelism
  - Maximum degrees of parallelism
  - Max Server Memory (MB)
- Filegrowth settings 
- Alerts
  - Severity 16
  - Severity 17
  - Severity 18
  - Severity 19
  - Severity 20
  - Severity 21
  - Severity 22
  - Severity 23
  - Severity 24
  - Severity 25
  - Error Number 823
  - Error Number 824
  - Error Number 825

## Installation

1. Clone or [download](https://github.com/pimbrouwers/sp_EasyButton/archive/master.zip) the repository.
2. Run `sp_EasyButton` in the master database, or whichever database you prefer.

## Parameters

> Running `sp_EasyButton` with no parameters, will output basic instructions.

- `@Configre bit` - run all sp_configure operations
- `@FileGrowth bit` - adjust filegrowth
- `@FileGrowthSysDbs bit` - include system databases (master, model, msdb)
- `@FileGrowthDataMB smallint` - MB value for data filegrowth (256 recommended)
- `@FileGrowthLogMB smallint` - MB value for log filegrowth (128 recommended)
- `@Alerts bit` - enable alerts
- `@OperatorName nvarchar(100)` - operator name for alert dispatch
- `@OperatorEmail nvarchar(320)` - operator eamil for alert dispatch

## License

[sp_EasyButton uses the GNU GENERAL PUBLIC LICENSE.](LICENSE.md)

[*Back to top*](#header1)

[licence badge]:https://img.shields.io/badge/license-GNU-blue.svg
[stars badge]:https://img.shields.io/github/stars/pimbrouwers/sp_EasyButton.svg
[forks badge]:https://img.shields.io/github/forks/pimbrouwers/sp_EasyButton.svg
[issues badge]:https://img.shields.io/github/issues/pimbrouwers/sp_EasyButton.svg

[licence]:https://github.com/pimbrouwers/sp_EasyButton/blob/master/LICENSE.md
[stars]:https://github.com/pimbrouwers/sp_EasyButton/stargazers
[forks]:https://github.com/pimbrouwers/sp_EasyButton/network
[issues]:https://github.com/pimbrouwers/sp_EasyButton/issues