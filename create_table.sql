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
    id           SERIAL          PRIMARY KEY,
    user_id      INT NOT NULL    REFERENCES "User"(id),
    publisher_id INT NOT NULL    REFERENCES Publisher(id)
);

CREATE TABLE IF NOT EXISTS Product (
    id              SERIAL                PRIMARY KEY,
    publisher_id    INT NOT NULL          REFERENCES Publisher(id),
    name            VARCHAR(255) NOT NULL,
    description     TEXT NOT NULL,
    price           MONEY NOT NULL,
    purchasers_count INT NOT NULL,
    reviews_count   INT NOT NULL,
    rating_sum      INT NOT NULL
);

CREATE TABLE IF NOT EXISTS AssignedTag (
    id         SERIAL PRIMARY KEY,
    tag_id     INT    REFERENCES Tag(id),
    product_id INT    REFERENCES Product(id)
);

CREATE TABLE IF NOT EXISTS Purchase (
    id         SERIAL        PRIMARY KEY,
    product_id INT NOT NULL  REFERENCES Product(id),
    buyer_id   INT NOT NULL  REFERENCES "User"(id),
    date       DATE NOT NULL
);

CREATE TABLE IF NOT EXISTS Gift (
    id           SERIAL                PRIMARY KEY,
    purchase_id  INT NOT NULL          REFERENCES Purchase(id),
    recipient_id INT NOT NULL          REFERENCES "User"(id),
    title        VARCHAR(255) NOT NULL,
    message      TEXT NOT NULL
);

CREATE TABLE IF NOT EXISTS Review (
    id         SERIAL           PRIMARY KEY,
    writer_id  INT NOT NULL     REFERENCES "User"(id),
    subject_id INT NOT NULL     REFERENCES Product(id),
    rating     SMALLINT NOT NULL,
    text       TEXT NOT NULL,
    date       DATE NOT NULL
);

CREATE TABLE IF NOT EXISTS Achievement (
    id              SERIAL                PRIMARY KEY,
    product_id      INT NOT NULL          REFERENCES Product(id),
    name            VARCHAR(255) NOT NULL,
    achievers_count INT NOT NULL
);

CREATE TABLE IF NOT EXISTS ObtainedAchievement (
    id             SERIAL       PRIMARY KEY,
    user_id        INT NOT NULL REFERENCES "User"(id),
    achievement_id INT NOT NULL REFERENCES Achievement(id)
);

CREATE TABLE IF NOT EXISTS ProductDependency (
    requester_id   SERIAL       PRIMARY KEY,
    user_id        INT NOT NULL REFERENCES Product(id)
);
