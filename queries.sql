-- Вывести все подарки (Gift), сделанные пользователю c User.id = 5, по убыванию даты

SELECT g.id, g.title, g.message, p.product_id, p.date
    FROM Gift AS g
    INNER JOIN Purchase AS p
    ON g.recipient_id = 5 AND g.purchase_id = p.id
    ORDER BY date DESC;


-- Вывести 10 издателей (Publisher), лидирующих по объему продаж их игр

WITH publisher_sales AS (
    SELECT publisher_id, SUM(purchasers_count) AS sales
    FROM Product AS prod
    GROUP BY publisher_id
)
SELECT pub.id, pub.name, pub.description, s.sales
    FROM publisher_sales AS s
    INNER JOIN Publisher AS pub
    ON s.publisher_id = pub.id
    ORDER BY sales DESC
    LIMIT 10;


-- Вывести весь не купленный пользователем дополнительный контент для некоторой игры (Product, ProductDependency) (1)
WITH RECURSIVE all_deps AS (
        SELECT DISTINCT
                Game.id,
                -1 AS parent,
                0 AS level
        FROM Product Game
        WHERE Game.id = 3
        UNION ALL
        SELECT
                Dep.id,
                prev.id,
                level + 1
        FROM all_deps AS prev
        INNER JOIN ProductDependency AS DepLink
                ON prev.id = DepLink.required_id
        INNER JOIN Product AS Dep
                ON Dep.id = DepLink.requester_id
),
purchased AS (
        SELECT id
        FROM Gift WHERE recipient_id = 1
        UNION ALL
        SELECT Purchase.id FROM Purchase
        INNER JOIN Gift
                ON Gift.purchase_id = Purchase.id
                WHERE recipient_id != 1
)
SELECT id FROM all_deps
        WHERE level != 0 AND id NOT IN (SELECT id FROM purchased);


-- найти суммарную стоимость продууктов предыдущего запроса (2)
WITH RECURSIVE all_deps AS (
        SELECT DISTINCT
                Game.id,
                -1 AS parent,
                0 AS level
        FROM Product Game
        WHERE Game.id = 3
        UNION ALL
        SELECT
                Dep.id,
                prev.id,
                level + 1
        FROM all_deps AS prev
        INNER JOIN ProductDependency AS DepLink
                ON prev.id = DepLink.required_id
        INNER JOIN Product AS Dep
                ON Dep.id = DepLink.requester_id
),
purchased AS (
        SELECT id
        FROM Gift WHERE recipient_id = 1
        UNION ALL
        SELECT Purchase.id FROM Purchase
        INNER JOIN Gift
                ON Gift.purchase_id = Purchase.id
                WHERE recipient_id != 1
)
SELECT SUM(Product.price) FROM all_deps
	INNER JOIN Product 
		ON Product.id = all_deps.id;
	WHERE (level != 0 AND id NOT IN (SELECT id FROM purchased))
