-- Вывести все подарки (Gift), сделанные пользователю c User.id = 2, по убыванию даты

SELECT g.id, g.title, g.message, p.product_id, p.date
	FROM Gift AS g
	INNER JOIN Purchase AS p
	ON g.recipient_id = 2 AND g.purchase_id = p.id
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
