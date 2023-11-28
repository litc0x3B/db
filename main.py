import psycopg2
from psycopg2 import Error as DbError
from faker import Faker
import requests
from bs4 import BeautifulSoup
from decimal import Decimal
from fill_tables import fill

db_name = 'myDatabaseName'


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

def clear_all(connection):
    sql = 'TRUNCATE ' + ', '.join([
        'Tag', 
        '"User"', 
        'Publisher', 
        'Publisher_User', 
        'Product', 
        'AssignedTag',
        'Purchase',
        'Gift',
        'Review',
        'Achievement',
        'ObtainedAchievement'
    ]) + ' RESTART IDENTITY'
    with connection, connection.cursor() as cursor:
        cursor.execute(sql)

connection = connect()
create_tables_if_not_exist(connection)
clear_all(connection)
fill(connection)
