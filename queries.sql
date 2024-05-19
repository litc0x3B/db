-- Выбрать все изображения имеющие определенный набор тегов (задаётся булевым выражением)
-- и отсортировать их по количеству добавлений в избранное.
-- В качестве булевого выражения взяли tag.name = ‘cute’

SELECT favorite_user_image.id_image, image.url, COUNT(*) as fav_count FROM tag 
JOIN image_tag ON tag.name = 'cute' and tag.id_tag = image_tag.id_tag
JOIN image ON image.id_image = image_tag.id_image
JOIN favorite_user_image ON favorite_user_image.id_image = image.id_image
GROUP BY favorite_user_image.id_image, image.url ORDER BY fav_count DESC

-- Выбрать топ n тегов по количеству добавлений в избранное содержащих их изображений за определенный период времени. 
-- n = 10, период времени - с 10.02.24
SELECT tag.id_tag, tag.name, COUNT(*) as fav_count FROM tag 
JOIN image_tag ON tag.id_tag = image_tag.id_tag
JOIN image ON image.id_image = image_tag.id_image
JOIN favorite_user_image ON DATE(favorite_user_image.created_at) > '20240302' AND favorite_user_image.id_image = image.id_image
GROUP BY  tag.id_tag, tag.name
ORDER BY fav_count 
DESC LIMIT 10

-- Выбрать все теги, которые имеются менее чем у n изображений.
-- n = 20
WITH tags_with_img_count (id_tag, name, img_count) AS
(
    SELECT tag.id_tag, tag.name, COUNT(*) as img_count FROM tag 
    JOIN image_tag ON tag.id_tag = image_tag.id_tag
    JOIN image ON image.id_image = image_tag.id_image
    GROUP BY tag.id_tag, tag.name
)
SELECT * FROM tags_with_img_count WHERE img_count < 20

-- Отобразить гистограмму количества публикации изображений, сгруппированных по определенным промежуткам времени, за определенный промежуток времени.
-- Гистограмма за период с 01.02.2024 по 21.05.2024, интервал группировки 10 дней
WITH hist AS
(
    SELECT 
        date_bin(interval '10 days', image.created_at, timestamp '20240201') as bin_center, 
        count(*)
        FROM image
        WHERE timestamp '20240201' < image.created_at AND image.created_at < timestamp '20240521'
        GROUP BY 1
        ORDER BY 1
)
SELECT 
    DATE(bin_center) || ' - ' || DATE(bin_center + interval '10 days') AS "interval",
    count
    FROM hist


-- Выбрать комментарии пользователей, зарегистрировавшихся за последнюю неделю
SELECT 
    "user".id_user, username, comment.id_comment, content, DATE(registration_time) as reg_time
    FROM "user"
    JOIN comment ON "user".id_user = comment.id_user
    WHERE   CURRENT_TIMESTAMP - INTERVAL '1 week' < "user".registration_time 
            and "user".registration_time < CURRENT_TIMESTAMP
