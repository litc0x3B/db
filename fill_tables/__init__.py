from typing import List, TypeVar
from .data import *
from .gen import *

def insert(connection, objs: List, klass: type[Data]):
    if not objs:
        return
    
    table = objs[0].table_name
    data = list(map(lambda x: x.__dict__, objs))
    for d in data:
        if klass.id_field_name in d:
            d.pop(klass.id_field_name)
    fields = data[0].keys()
    fields_str = f"({', '.join(fields)})"
    values = map(lambda x: x.values(), data)
    values_str = ', '.join(map(
        lambda x: f"({', '.join(map(to_str_value, x))})",
        values
    ))

    sql = f"INSERT INTO {table} {fields_str} VALUES {values_str}"
    with connection, connection.cursor() as cursor:
        cursor.execute(sql)

def select_all(connection, klass: type[Data]) -> List[Data]:
    table = klass.table_name
    sql = f"SELECT * FROM {table}"
    with connection, connection.cursor() as cursor:
        cursor.execute(sql)
        values = cursor.fetchall()
        fields = [desc[0] for desc in cursor.description]
    args = map(lambda v: dict(zip(fields, v)), values)
    return list(map(lambda x: klass(**x), args))

def fill(conn):
    insert(conn, list(gen_users(5000)), User)
    users = select_all(conn, User)
    
    insert(conn, list(gen_images(users, 10)), Image)
    images = select_all(conn, Image)
    
    insert(conn, list(gen_categories()), TagCategory)
    categories = select_all(conn, TagCategory)
    
    insert(conn, list(gen_tags(categories)), Tag)
    tags = select_all(conn, Tag)
    
    insert(conn, list(set(gen_image_tags(images, tags))), ImageTag)
    insert(conn, list(gen_comments(users, images, 5)), Comment)
    insert(conn, list(gen_favorites(users, images, 20)), FavoriteUserImage)