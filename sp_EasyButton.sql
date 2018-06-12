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
  @Configuration bit = 1
  ,@FileGrowth bit = 1
  ,@TempDb bit = 1
as

  /*
    Configuration
  */
  if @Configuration = 1
    begin
      print ('----------------');
      print ('-- CONFIGURATION');
      print ('----------------');

      -- ARITHABORT
      -- https://docs.microsoft.com/en-us/sql/t-sql/statements/set-arithabort-transact-sql      
      exec sys.sp_configure
        N'user options'
        ,N'64';

      reconfigure;

      -- Show Advanced Options
      -- https://docs.microsoft.com/en-us/sql/database-engine/configure-windows/show-advanced-options-server-configuration-option      
      exec sys.sp_configure
        'show advanced options'
        ,1;

      reconfigure;

      -- Backup Compression
      -- https://www.brentozar.com/archive/2013/09/five-sql-server-settings-to-change/      
      exec sys.sp_configure
        'backup compression default'
        ,'1';

      reconfigure;

      -- Cost Threshold for parallelism
      -- https://www.brentozar.com/archive/2013/09/five-sql-server-settings-to-change/      
      exec sys.sp_configure
        'cost threshold for parallelism'
        ,'50';

      reconfigure;

      -- Lightweight pooling
      -- http://dataeducation.com/the-sql-hall-of-shame/      
      exec sys.sp_configure
        'lightweight pooling'
        ,'0';

      reconfigure;

      -- Priority Boost
      -- http://dataeducation.com/the-sql-hall-of-shame/ 
      exec sys.sp_configure
        'priority boost'
        ,'0';

      reconfigure;

      -- Remote DAC
      -- https://www.brentozar.com/archive/2013/09/five-sql-server-settings-to-change/
      exec sys.sp_configure
        'remote admin connections'
        ,'1';

      reconfigure;

      -- Maximum degrees of parallelism
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

      select @logicalProcessors = cpu_count from sys.dm_os_sys_info;

      if @numaNodes = 1
         or @logicalProcessors < 8
        begin
          set @maxDop = @logicalProcessors;
        end;

      exec sys.sp_configure
        'max degree of parallelism'
        ,@maxDop;

      reconfigure;

      -- Max Server Memory (MB)
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
      print ('-------------');
      print ('-- FILEGROWTH');
      print ('-------------');

      print ('master (data: 256mb, log: 128mb)');
      alter database master
        modify file (name = 'master', filegrowth = 256mb);

      alter database master
        modify file (name = 'mastlog', filegrowth = 128mb);

      print ('msdb (data: 256mb, log: 128mb)');
      alter database msdb
        modify file (name = 'MSDBData', filegrowth = 256mb);

      alter database msdb
        modify file (name = 'MSDBLog', filegrowth = 128mb);

      print ('model (data: 256mb, log: 128mb)');
      alter database model
        modify file (name = 'modeldev', filegrowth = 256mb);

      alter database model
        modify file (name = 'modellog', filegrowth = 128mb);
    end;
go