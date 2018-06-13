/*
sp_EasyButton

One-button server configuration to implement 
accepted best practices.

Credit: Pim Brouwers

Source: https://github.com/pimbrouwers/sp_EasyButton
*/

if object_id('dbo.sp_EasyButton') is null
  exec ('create procedure dbo.sp_EasyButton as return 0;');
go

alter procedure dbo.sp_EasyButton
  @Configure bit = 0
  ,@FileGrowth bit = 0
  ,@FileGrowthSysDbs bit = 0
  ,@FileGrowthDataMB int = 256
  ,@FileGrowthLogMB int = 128
  ,@TempDb bit = 0
as
  /*
  Version Detection
  */
  declare @VersionNumber int;
  declare @ProductVersion varchar(25) = cast(serverproperty('ProductVersion') as varchar(25));

  set @VersionNumber = cast(substring(@ProductVersion, 1, charindex('.', @ProductVersion) - 1) as int);

  /*
  Configuration
  */
  if @Configure = 1
    begin
      print ('----------------');
      print ('-- CONFIGURATION');
      print ('----------------');

      -- ARITHABORT
      -- https://docs.microsoft.com/en-us/sql/t-sql/statements/set-arithabort-transact-sql      
      exec sys.sp_configure
        N'user options'
        ,N'64';

      -- Show Advanced Options
      -- https://docs.microsoft.com/en-us/sql/database-engine/configure-windows/show-advanced-options-server-configuration-option      
      exec sys.sp_configure
        'show advanced options'
        ,1;

      -- Backup Compression
      -- 2005+ (v9.0)
      -- This way no matter who takes the backup, it will be compressed
      -- https://www.brentozar.com/archive/2013/09/five-sql-server-settings-to-change/      
      if @VersionNumber > 9
        exec sys.sp_configure
          'backup compression default'
          ,'1';

      -- Cost Threshold for parallelism
      -- If you see a lot of CXPACKET waits on your system together with High CPU usage, 
      -- consider reviewing this parameter further together with the MAXDOP.
      -- https://www.brentozar.com/archive/2013/09/five-sql-server-settings-to-change/      
      exec sys.sp_configure
        'cost threshold for parallelism'
        ,'50';

      -- Lightweight pooling
      -- https://docs.microsoft.com/en-us/sql/relational-databases/policy-based-management/disable-lightweight-pooling      
      exec sys.sp_configure
        'lightweight pooling'
        ,'0';

      -- Priority Boost
      -- http://dataeducation.com/the-sql-hall-of-shame/ 
      exec sys.sp_configure
        'priority boost'
        ,'0';

      -- Remote DAC
      -- https://www.brentozar.com/archive/2013/09/five-sql-server-settings-to-change/
      exec sys.sp_configure
        'remote admin connections'
        ,'1';

      -- Maximum degrees of parallelism
      -- Represents the number of CPU that a single query can use. A value of 0 means 
      -- you are letting SQL Server decide how many, of which it will use all available
      -- (up to 64). You’ll end up using all your CPUs for each and every query, if by 
      -- chance, you didn't change the Cost Threshold for Parallelism (from the default of 5). 
      -- https://support.microsoft.com/en-ca/help/2806535/recommendations-and-guidelines-for-the-max-degree-of-parallelism-confi
      declare
        @numaNodes int
        ,@logicalProcessors int
        ,@maxDop int = 8;

      select
        @numaNodes = count(*)
      from
        sys.dm_os_memory_nodes
      where
        memory_node_id <> 64;

      select
        @logicalProcessors = cpu_count
      from
        sys.dm_os_sys_info;

      if @numaNodes = 1
         or @logicalProcessors < 8
        begin
          set @maxDop = @logicalProcessors;
        end;

      exec sys.sp_configure
        'max degree of parallelism'
        ,@maxDop;

      -- Max Server Memory (MB)
      -- The default value is ALL of your server's memory. Yes. All. As a baseline
      -- leave 25% for the OS (optimistic). But if the total memory available to this 
      -- instance is > 32GB than 12.5% should be sufficient for the OS to operate.
      -- https://www.brentozar.com/blitz/max-memory/
      declare
        @systemMemory int
        ,@maxServerMemory int;

      select
        @systemMemory = total_physical_memory_kb / 1024
      from
        sys.dm_os_sys_memory;

      set @maxServerMemory = floor(@systemMemory * .75);

      if @systemMemory >= 32768
        begin
          set @maxServerMemory = floor(@systemMemory * .875);
        end;

      exec sys.sp_configure
        'max server memory (MB)'
        ,@maxServerMemory;

      reconfigure;
    end;

  /*
  Filegrowth
  */
  if @FileGrowth = 1
    begin
      print ('');
      print ('---------------------------------------');
      print ('-- FILEGROWTH (data: ' + cast(@FileGrowthDataMB as varchar(25)) + 'MB, log: ' + cast(@FileGrowthLogMB as varchar(25)) + 'MB)');
      print ('---------------------------------------');

      declare @sql nvarchar(max);

      ;with files as (
        select
          f.*
          ,db_name(f.database_id) as dbname
          ,p.name as ownername
        from
          sys.master_files f with (nolock)
        join
          sys.databases d with (nolock)
          on d.database_id = f.database_id
        join
          sys.server_principals p with (nolock)
          on p.sid = d.owner_sid
      )
      ,dbs as (
        select
          f.dbname
          ,cast(f.name as varchar(128)) as filename
          ,cast(l.logfilename as varchar(128)) as logfilename
          ,f.ownername
        from
          files f
        cross apply (
          select
            l.name as logfilename
          from
            files l
          where
            l.type = 1
            and l.database_id = f.database_id
        ) l
        where
          f.type = 0
          and db_name(f.database_id) <> 'tempdb'
      )
      select
        @sql = stuff((
                       select
                         'alter database ' + dbs.dbname + ' modify file (name = ' + dbs.filename + ', filegrowth = ' + cast(@FileGrowthDataMB as varchar(25)) + '); ' + 
                         'alter database ' + dbs.dbname + ' modify file (name = ' + dbs.logfilename + ', filegrowth = ' + cast(@FileGrowthLogMB as varchar(25)) + '); ' +
                         'print (''' + dbs.dbname + ''');'
                       from
                         dbs
                       where
                         @FileGrowthSysDbs = 1
                         or dbs.ownername <> 'sa'
                       for xml path('')
                     ), 1, 0, ''
               );

      exec (@sql);
    end;
go