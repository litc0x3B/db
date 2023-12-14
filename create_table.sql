CREATE TABLE IF NOT EXISTS Tag (
    id   SERIAL                PRIMARY KEY,
    name VARCHAR(255) NOT NULL UNIQUE
);

CREATE TABLE IF NOT EXISTS "User" (
    id       SERIAL       PRIMARY KEY,
    email    VARCHAR(255) NOT NULL,
    password VARCHAR(255) NOT NULL,
    username VARCHAR(255) NOT NULL,
    money    MONEY NOT NULL
);

CREATE TABLE IF NOT EXISTS Publisher (
    id          SERIAL       PRIMARY KEY,
    name        VARCHAR(255) NOT NULL,
    description TEXT NOT NULL
);

CREATE TABLE IF NOT EXISTS Publisher_User (
    user_id      INT NOT NULL    REFERENCES "User"(id),
    publisher_id INT NOT NULL    REFERENCES Publisher(id)
    PRIMARY KEY (user_id, publisher_id)
);

CREATE TABLE IF NOT EXISTS Product (
    id               SERIAL                PRIMARY KEY,
    publisher_id     INT NOT NULL          REFERENCES Publisher(id),
    name             VARCHAR(255) NOT NULL,
    description      TEXT NOT NULL,
    price            MONEY NOT NULL,
    purchasers_count INT NOT NULL,
    reviews_count    INT NOT NULL,
    rating_sum       INT NOT NULL
);

CREATE TABLE IF NOT EXISTS AssignedTag (
    tag_id     INT    REFERENCES Tag(id) ON DELETE CASCADE,
    product_id INT    REFERENCES Product(id) ON DELETE CASCADE,
    PRIMARY KEY (tag_id, product_id)
);

CREATE TABLE IF NOT EXISTS Purchase (
    id         SERIAL        PRIMARY KEY,
    product_id INT NOT NULL  REFERENCES Product(id) ON DELETE CASCADE,
    buyer_id   INT NOT NULL  REFERENCES "User"(id) ON DELETE CASCADE,
    date       TIMESTAMP NOT NULL
);

CREATE TABLE IF NOT EXISTS Gift (
    id           SERIAL                PRIMARY KEY,
    purchase_id  INT NOT NULL          REFERENCES Purchase(id),
    recipient_id INT NOT NULL          REFERENCES "User"(id) ON DELETE CASCADE,
    title        VARCHAR(255) NOT NULL,
    message      TEXT NOT NULL
);

CREATE TABLE IF NOT EXISTS Review (
    id         SERIAL           PRIMARY KEY,
    writer_id  INT              REFERENCES "User"(id),
    subject_id INT NOT NULL     REFERENCES Product(id) ON DELETE CASCADE,
    rating     SMALLINT NOT NULL,
    text       TEXT NOT NULL,
    date       TIMESTAMP NOT NULL
);

CREATE TABLE IF NOT EXISTS Achievement (
    id              SERIAL                PRIMARY KEY,
    product_id      INT NOT NULL          REFERENCES Product(id) ON DELETE CASCADE,
    name            VARCHAR(255) NOT NULL,
    achievers_count INT NOT NULL
);

CREATE TABLE IF NOT EXISTS ObtainedAchievement (
    user_id        INT NOT NULL REFERENCES "User"(id) ON DELETE CASCADE,
    achievement_id INT NOT NULL REFERENCES Achievement(id) ON DELETE CASCADE
    PRIMARY KEY (user_id, achievement_id)
);

CREATE TABLE IF NOT EXISTS ProductDependency (
    requester_id INT NOT NULL PRIMARY KEY REFERENCES Product(id) ON DELETE CASCADE,
    required_id  INT NOT NULL             REFERENCES Product(id)
);


CREATE OR REPLACE FUNCTION recalc_achievement_owners_on_new_obtained()
  RETURNS TRIGGER AS $$
BEGIN
  UPDATE Achievement
    SET achievers_count = achievers_count + 1
    WHERE NEW.achievement_id = id;
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE TRIGGER recalc_achievement_owners_on_new_obtained
AFTER INSERT ON ObtainedAchievement
FOR EACH ROW
EXECUTE PROCEDURE recalc_achievement_owners_on_new_obtained();

CREATE OR REPLACE FUNCTION recalc_product_purchases_on_new()
  RETURNS TRIGGER AS $$
BEGIN
  UPDATE Product 
    SET purchasers_count = purchasers_count + 1
    WHERE NEW.subject_id = id;
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE TRIGGER recalc_product_purchases_on_new
AFTER INSERT ON Review
FOR EACH ROW
EXECUTE PROCEDURE recalc_product_purchases_on_new();

CREATE OR REPLACE FUNCTION recalc_product_rating_stats_on_new_review()
  RETURNS TRIGGER AS $$
BEGIN
  UPDATE Product 
    SET rating_sum = rating_sum + NEW.rating, reviews_count = reviews_count + 1
    WHERE NEW.subject_id = id;
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE TRIGGER recalc_product_rating_stats_on_new_review
AFTER INSERT ON Review
FOR EACH ROW
EXECUTE PROCEDURE recalc_product_rating_stats_on_new_review();


CREATE OR REPLACE FUNCTION new_product_dependency_validate()
  RETURNS TRIGGER AS $$
BEGIN
  IF
    NEW.requester_id IN (SELECT requester_id from ProductDependency as pd1)
    OR 
    NEW.requester_id IN (SELECT required_id from ProductDependency as pd2) 
  THEN
    RAISE EXCEPTION 'This requester [requester_id:%] is already used!', NEW;
  END IF;
  
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE TRIGGER new_dependency_validate
BEFORE INSERT ON ProductDependency
FOR EACH ROW
EXECUTE FUNCTION new_product_dependency_validate();

-- ON DELETE Review
CREATE OR REPLACE FUNCTION recalc_product_rating_stats_on_delete_review()
  RETURNS TRIGGER AS $$
BEGIN
  UPDATE Product
    SET rating_sum = rating_sum - OLD.rating, reviews_count = reviews_count - 1
    WHERE OLD.subject_id = id;
  RETURN OLD;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE TRIGGER recalc_product_rating_stats_on_delete_review
AFTER DELETE ON Review
FOR EACH ROW
EXECUTE PROCEDURE recalc_product_rating_stats_on_delete_review();

-- ON DELETE Gift
--CREATE OR REPLACE FUNCTION assign_purchase_recipient_on_gift_delete()
--  RETURNS TRIGGER AS $$
--BEGIN
--  UPDATE Purchase 
--    SET buyer_id = OLD.recipient_id 
--    WHERE id = OLD.purchase_id;
--  RETURN OLD;
--END;

-- CREATE OR REPLACE TRIGGER recalc_product_rating_stats_on_delete_review
-- BEFORE DELETE ON
-- FOR EACH ROW
-- EXECUTE PROCEDURE assign_purchase_recipient_on_gift_delete();

-- ON DELETE Achivement
CREATE OR REPLACE FUNCTION recalc_achievement_owners_on_delete_obtained()
  RETURNS TRIGGER AS $$
BEGIN
  UPDATE Achievement
    SET achievers_count = achievers_count - 1
    WHERE OLD.achievement_id = id;
  RETURN NULL;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE TRIGGER recalc_achievement_owners_on_delete_obtained
AFTER DELETE ON ObtainedAchievement
FOR EACH ROW
EXECUTE PROCEDURE recalc_achievement_owners_on_delete_obtained();

-- ON DELETE User
-- CREATE OR REPLACE FUNCTION delete_user_if_not_last_publisher_owner()
--   RETURNS TRIGGER AS $$
-- BEGIN
--   IF (SELECT count(DISTINCT user_id) FROM Publisher_User WHERE user_id = OLD.id) > 1
--   THEN
--       RETURN OLD;
--    ELSE
--       RETURN NULL;
--    END IF;
-- END;
-- $$ LANGUAGE plpgsql;

-- CREATE OR REPLACE TRIGGER delete_user_if_not_last_publisher_owner
-- BEFORE DELETE ON ObtainedAchievement
-- FOR EACH ROW
-- EXECUTE PROCEDURE delete_user_if_not_last_publisher_owner();
