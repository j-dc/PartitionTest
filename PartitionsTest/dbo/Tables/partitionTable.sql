CREATE TABLE [dbo].[partitionTable] (
   [Timestamp]  DATETIME2 (2)                               NOT NULL,
   [PartitionTableId]   INT                                         NOT NULL,
   [Value]        DECIMAL (19, 10)                            NULL,
    CONSTRAINT [PK_PartitionTable] PRIMARY KEY CLUSTERED ([Timestamp] ASC, [PartitionTableId] ASC) 
) on [PS_TEST] ([Timestamp])
WITH (
    DATA_COMPRESSION = PAGE
 );