CREATE TABLE [dbo].[partitionTable] (
    [PartitionTableId]   INT                                         NOT NULL,
    [Timestamp]  DATETIME2 (2)                               NOT NULL,
    [Value]        DECIMAL (19, 10)                            NULL,
    CONSTRAINT [PK_Measurement_Alerting] PRIMARY KEY CLUSTERED ([Timestamp] ASC, [PartitionTableId] ASC) 
) on [PS_TEST] ([Timestamp])
WITH (
    DATA_COMPRESSION = PAGE
 );