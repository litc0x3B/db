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