from typing import ClassVar, Optional, List, Iterable, Dict
from faker import Faker
from .data import *
from .tags import categories_dict
from functools import lru_cache
import requests
from random import randint, choices as rchoices, sample as rsample
from utils import PositiveInt
import bcrypt
import pandas as pd
# from .tags import tags
from .game_names import game_names
from datetime import datetime, date
from ast import literal_eval
import urllib

IMAGE_RESOLUTIONS = [   (500, 480),
                        (720, 480),
                        (720, 480),
                        (854, 480),
                        (720, 576),
                        (720, 576),
                        (1280, 720), 
                        (1440, 1080),
                        (1920, 1080),
                        (1998, 1080),
                        (2048, 1080),
                        (3840, 2160),
                        (4096, 2160),
                        (7680, 4320),
                        (15360, 8640),
                        (30720, 17280),]

STATIC_WEB_SITE_URL = 'https://static.oursite.ru/'
WEB_SITE_URL = 'https://oursite.ru/'

_faker = Faker()

class NoneIdException(Exception):
    def __init__(self):
        super().__init__('id must not be None in gen')

def gen_users(n: PositiveInt) -> Iterable[User]:
    for i in range(n):
        yield User (None,
                    _faker.user_name()[:],
                    _faker.date_time_this_year(),
                    _faker.unique.user_name(),
                    _faker.pystr(60, 60).encode(),
                    # bcrypt.hashpw(_faker.password().encode(), bcrypt.gensalt(4)),
                    STATIC_WEB_SITE_URL + "profile-pics/" + str(_faker.unique.random_int(50000, 1000000)) + ".jpeg",
                    Role(rchoices(range(0, 3), weights=[30, 1, 2])[0]))

metadata = pd.read_csv('./metadata.csv')

def gen_images(users: List[User], max_per_user: PositiveInt):
    image_count = 0
    for user in users:
        for i in range(randint(0, max_per_user)):
            if user.id_user is None:
                raise NoneIdException
            resolution = (224, 224)
            yield Image (None,
                        STATIC_WEB_SITE_URL + metadata.image_path[image_count],
                        _faker.date_time_this_year(),
                        'https://www.kaggle.com/datasets/greg115/various-tagged-images/',
                        resolution[0], resolution[1],
                        user.id_user
                        )
            image_count += 1


def gen_image_tags(images: List[Image], tags: list[Tag]):
    tags_dict : Dict[str, Tag] = dict() 
    for tag in tags:
        tags_dict[tag.name] = tag
        
    for image in images:
        if image.id_image is None:
            raise NoneIdException
        
        for tag_name in literal_eval(metadata.tags[image.id_image - 1]):
            if tag_name in tags_dict:
                
                if tags_dict[tag_name].id_tag is None:
                    raise NoneIdException
                
                yield ImageTag(image.id_image, tags_dict[tag_name].id_tag)

                
def gen_comments(users: List[User], images: List[Image], max_comments_per_user: PositiveInt):
    for user in users:
        for image in rchoices(images, k=randint(0, max_comments_per_user)):
            if user.id_user is None or image.id_image is None:
                raise NoneIdException
            yield Comment(  None,
                            _faker.paragraph(),
                            _faker.date_time_this_year(),
                            user.id_user, image.id_image)


def gen_favorites(users: List[User], images: List[Image], max_favorites_per_user: PositiveInt):
    for user in users:
        for image in rsample(images, k=randint(0, max_favorites_per_user)):
            if user.id_user is None or image.id_image is None:
                raise NoneIdException
            yield FavoriteUserImage(user.id_user, image.id_image,
                                    _faker.date_time_this_year())
            


def gen_categories():
    for category_name in categories_dict.keys():
        yield TagCategory(  None,
                            category_name,
                            WEB_SITE_URL + 'tag-categories/' + category_name.replace(' & ', '+').replace(' ', '+'))


def gen_tags(categories: List[TagCategory]):
    for category in categories:
        for tag_name in categories_dict[category.name]:
            if category.id_tag_category is None:
                raise NoneIdException
            yield Tag(  None,
                        tag_name,
                        WEB_SITE_URL + 'tags/' + tag_name,
                        category.id_tag_category,
                        )