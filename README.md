# sp_EasyButton
<a name="header1"></a>
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