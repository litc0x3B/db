-- 1. Вывести все подарки (Gift), сделанные пользователю c User.id = 5, по убыванию даты

SELECT g.id AS gift_id, g.title, g.message, p.product_id, p.date
	FROM Gift AS g
	INNER JOIN Purchase AS p
	ON g.recipient_id = 5 AND g.purchase_id = p.id
	ORDER BY date DESC;


-- 2. Вывести 10 издателей (Publisher), лидирующих по объему продаж их игр

WITH publisher_sales AS (
	SELECT publisher_id, SUM(purchasers_count) AS sales
	FROM Product AS prod
	GROUP BY publisher_id
)
SELECT pub.id AS pub_id, pub.name, pub.description, s.sales
	FROM publisher_sales AS s
	INNER JOIN Publisher AS pub
	ON s.publisher_id = pub.id
	ORDER BY sales DESC
	LIMIT 10;


-- 3. Сгруппировать игры издателя с Publisher.id = 1 по тегам и вывести эти теги в порядке убывания частоты их появления

WITH publisher_tags AS (
	SELECT prod.publisher_id, at.tag_id, COUNT(*) AS tag_count
	FROM Product AS prod
	INNER JOIN AssignedTag AS at
	        ON prod.id = at.product_id
                WHERE prod.publisher_id = 1
	GROUP BY prod.publisher_id = 1, at.tag_id
	ORDER BY tag_count DESC
)
SELECT pt.publisher_id, pub.name AS publisher_name, pt.tag_id, t.name AS tag_name, pt.tag_count
	FROM publisher_tags AS pt
	INNER JOIN Publisher AS pub
	ON pub.id = pt.publisher_id
	INNER JOIN Tag AS t
	ON pt.tag_id = t.id;
	

-- 4. Вывести все достижения (Achievement) в игре с Product.id = 1: сначала полученные пользователем с User.id = 1 в
-- порядке убывания кол-ва получивших его игроков, затем не полученные в том же порядке, с указанием процента получивших их игроков
-- ВОЗМОЖНА ОШИБКА В ФОРМИРОВАНИИ ПОЛЯ obtainment

SELECT
	"user".id AS user_id,
	"user".username,
	ach.id AS ach_id,
	ach.name AS ach_name,
	obt.user_id IS NOT NULL AS obtainment,
	CAST(ach.achievers_count / prod.purchasers_count AS float) AS percentage
FROM (SELECT * FROM Achievement AS ach WHERE ach.product_id = 1) AS ach
	LEFT JOIN ObtainedAchievement AS obt
		ON obt.user_id = 1 AND ach.id = obt.achievement_id
	CROSS JOIN (SELECT * FROM "User" AS "user" WHERE "user".id = 1) AS "user"
	INNER JOIN Product AS prod
		ON prod.id = ach.product_id
	ORDER BY obtainment DESC, percentage DESC;


-- 5. Вывести последний положительный (Review.rating > 3.0) и последний отрицательный (Review.rating <= 3.0) обзоры (Review) 
-- на игру с Product.id = 1, авторами которых являются пользователи, написавшие не менее 2-х обзоров РАНЕЕ

WITH reliable_reviews AS (
	SELECT rev.*, row_number() OVER (PARTITION BY rev.writer_id ORDER BY rev.date ASC) AS ordinal
	FROM Review AS rev
)
SELECT * FROM
(
	SELECT 
		rel_rev.id,
		rel_rev.rating,
		rel_rev.text,
		rel_rev.date,
		rel_rev.writer_id,
		rel_rev.subject_id
	FROM reliable_reviews AS rel_rev
	WHERE rel_rev.subject_id = 1 AND rel_rev.ordinal >= 2 AND rel_rev.rating > 3
	ORDER BY date DESC
	LIMIT 1
)
UNION ALL
SELECT * FROM (
	SELECT
		rel_rev.id,
		rel_rev.rating,
		rel_rev.text,
		rel_rev.date,
		rel_rev.writer_id,
		rel_rev.subject_id
	FROM reliable_reviews AS rel_rev
	WHERE rel_rev.subject_id = 1 AND rel_rev.ordinal >= 2 AND rel_rev.rating <= 3
	ORDER BY date DESC
	LIMIT 1
);


-- 6. Вывести всю библиотеку игр (Product) пользователя c User.id = 1
WITH library_purchases AS (
	SELECT g.purchase_id
		FROM Gift AS g
		WHERE recipient_id = 1
	UNION ALL
	SELECT pur.id AS purchase_id
		FROM (SELECT * FROM Purchase AS pur WHERE pur.buyer_id = 1) AS pur
		LEFT JOIN Gift AS g
		ON pur.id = g.purchase_id
		WHERE g.purchase_id IS NULL
)
SELECT DISTINCT ON (prod.id) prod.*, pur.date
	FROM library_purchases AS lib_pur
	INNER JOIN Purchase AS pur
	ON lib_pur.purchase_id = pur.id
	INNER JOIN Product AS prod
	ON pur.product_id = prod.id;


-- 7. Вывести 10 самых продаваемых игр за последние 30 дней [или за текущий месяц? или за год? или как лучше то?]

WITH product_sales AS (
	SELECT pur.product_id, COUNT(*) AS last_30_days_sales
	FROM Purchase AS pur
	WHERE pur.date > CURRENT_TIMESTAMP - INTERVAL '30 days'
	GROUP BY pur.product_id
	ORDER BY last_30_days_sales DESC
	LIMIT 10
)
SELECT prod.*, sales.last_30_days_sales
	FROM product_sales as sales
	INNER JOIN Product as prod
	ON sales.product_id = prod.id
	ORDER BY last_30_days_sales DESC;


-- 8. Вывести 3 самых редких достижения (Achievement) среди полученных пользователем с User.id = 1 с указанием процента получивших их игроков

SELECT "user".id AS user_id, "user".username, ach.id AS ach_id, ach.name AS ach_name, CAST(ach.achievers_count / prod.purchasers_count AS float) AS percentage
	FROM Achievement AS ach
	INNER JOIN ObtainedAchievement AS obt
	ON obt.user_id = 1 AND ach.id = obt.achievement_id
	CROSS JOIN (SELECT * FROM "User" AS "user" WHERE "user".id = 1) AS "user"
	INNER JOIN Product AS prod
	ON prod.id = ach.product_id
	ORDER BY percentage ASC
	LIMIT 3;


-- Вывести весь не купленный пользователем дополнительный контент для некоторой игры (Product, ProductDependency) (1)
WITH RECURSIVE all_deps AS (
    SELECT DISTINCT
        Game.id,
        1 AS parent,
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
library_purchases AS (
	SELECT g.purchase_id
		FROM Gift AS g
		WHERE recipient_id = 1
	UNION ALL
	SELECT pur.id AS purchase_id
		FROM (SELECT * FROM Purchase AS pur WHERE pur.buyer_id = 1) AS pur
		LEFT JOIN Gift AS g
		ON pur.id = g.purchase_id
		WHERE g.purchase_id IS NULL
),
lib AS (
    SELECT DISTINCT ON (prod.id) prod.*, pur.date
    FROM library_purchases AS lib_pur
    INNER JOIN Purchase AS pur
        ON lib_pur.purchase_id = pur.id
    INNER JOIN Product AS prod
        ON pur.product_id = prod.id
)
SELECT id FROM all_deps
    WHERE level != 0 AND id NOT IN (SELECT id FROM lib);


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
library_purchases AS (
	SELECT g.purchase_id
		FROM Gift AS g
		WHERE recipient_id = 1
	UNION ALL
	SELECT pur.id AS purchase_id
		FROM (SELECT * FROM Purchase AS pur WHERE pur.buyer_id = 1) AS pur
		LEFT JOIN Gift AS g
		ON pur.id = g.purchase_id
		WHERE g.purchase_id IS NULL
),
lib AS (
    SELECT DISTINCT ON (prod.id) prod.*, pur.date
    FROM library_purchases AS lib_pur
    INNER JOIN Purchase AS pur
        ON lib_pur.purchase_id = pur.id
    INNER JOIN Product AS prod
        ON pur.product_id = prod.id
)
SELECT SUM(Product.price) FROM all_deps
	INNER JOIN Product 
		ON Product.id = all_deps.id;
	WHERE (level != 0 AND id NOT IN (SELECT id FROM lib))
