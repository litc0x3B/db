import psycopg2
from psycopg2 import Error as DbError
from faker import Faker
import requests
from bs4 import BeautifulSoup
from decimal import Decimal
from fill_tables import fill

db_name = 'images'


def connect():
    return psycopg2.connect(
        user="postgres",
        password="password",
        host="192.168.1.48",
        port="5432",
        database=db_name
    )

def create_tables(connection):
    with open('create_table.sql') as file:
        sql = file.read()
    with connection, connection.cursor() as cursor:
        cursor.execute(sql)

def drop_public(connection):
    sql = 'DROP SCHEMA public CASCADE; CREATE SCHEMA public;'
    with connection, connection.cursor() as cursor:
        cursor.execute(sql)

connection = connect()
create_tables(connection)
fill(connection)