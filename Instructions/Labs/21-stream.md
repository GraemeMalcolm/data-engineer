SELECT
    EventProcessedUtcTime AS OrderDateTime,
    ProductID,
    Quantity
INTO
    [FactOrder]
FROM
    [orders]



SELECT
    DateAdd(second,-5,System.TimeStamp) AS StartTime,
    System.TimeStamp AS EndTime,
    ProductID,
    SUM(Quantity) AS Orders
INTO
    [datalake]
FROM
    [orders]
GROUP BY ProductID, SlidingWindow(second, 5)
HAVING COUNT(*) > 1