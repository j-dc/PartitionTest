﻿CREATE PARTITION FUNCTION [PF_TEST](DATETIME2 (2))
    AS RANGE LEFT
    FOR VALUES (
       '2023-01-01 00:00:00', '2023-02-01 00:00:00'
    );
