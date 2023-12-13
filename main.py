import psycopg2
from psycopg2 import Error as DbError
from faker import Faker
import requests
from bs4 import BeautifulSoup
from decimal import Decimal
from fill_tables import fill

db_name = 'steam'


def connect():
    return psycopg2.connect(
        user="postgres",
        password="1",
        host="127.0.0.1",
        port="5432",
        database=db_name
    )

def create_tables_if_not_exist(connection):
    with open('create_table.sql') as file:
        sql = file.read()
    with connection, connection.cursor() as cursor:
        cursor.execute(sql)

def drop_public(connection):
    sql = 'DROP SCHEMA public CASCADE; CREATE SCHEMA public;'
    with connection, connection.cursor() as cursor:
        cursor.execute(sql)

connection = connect()
drop_public(connection)
create_tables_if_not_exist(connection)
fill(connection)