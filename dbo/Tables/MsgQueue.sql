CREATE TABLE [dbo].[MsgQueue] (
    [Iid]             BIGINT IDENTITY (1, 1) NOT NULL,
    [MsgValue]        VARCHAR(5000) NOT NULL,
    [MsgPriority]     INT,
    [MsgCatagory]     VARCHAR(500),
    [bMsgSent]        BIT DEFAULT 0,
    [MsgInTs]         DATETIME,
    [MsgOutTs]        DATETIME)
GO
