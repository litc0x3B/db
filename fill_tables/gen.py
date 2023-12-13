from typing import ClassVar, Optional, List, Iterable
from faker import Faker
from .data import *
from functools import lru_cache
import requests
from bs4 import BeautifulSoup
from random import randint, choices as rchoices
from utils import PositiveInt
from .tags import tags
from .game_names import game_names


_faker = Faker()

class NoneIdException(Exception):
    def __init__(self):
        super().__init__('id must not be None in gen')


def gen_obtained_achievements(
    achievements: List[Achievement],
    users: List[User],
) -> Iterable[ObtainedAchievement]:
    for achievement in achievements:
        for user in rchoices(users, k=randint(0, 10)):
            if (user.id is None) or (achievement.id is None):
                raise NoneIdException()
            yield ObtainedAchievement(
                None,
                user.id,
                achievement.id
            )


def gen_achievements(
    products: List[Product],
    n: PositiveInt
) -> Iterable[Achievement]:
    for product in rchoices(products, k=n):
        if product.id is None:
            raise NoneIdException()
        yield Achievement(
            None,
            product.id,
            _faker.text(50),
            0,
        )


def gen_reviews(
    products: List[Product], 
    recipients: List[User]
) -> Iterable[Review]:
    for recipient in rchoices(recipients):
        for product in rchoices(products, k=_faker.pyint(0,len(products))):
            if (product.id is None) or (recipient.id is None):
                raise NoneIdException()
            yield Review(
                None,
                product.id,
                recipient.id,
                _faker.text(),
                _faker.pyint(0,10),
                _faker.date()
            )


def gen_gifts(
    purchases: List[Purchase],
    recipients: List[User],
    n: PositiveInt,
) -> Iterable[Gift]:
    for recipient in rchoices(recipients, k=n):
        purchase = rchoices(purchases, k=1)[0]
        while purchase.buyer_id == recipient:
            purchase = rchoices(purchases, k=1)[0]            
        if (purchase.id is None) or (recipient.id is None):
            raise NoneIdException()
        yield Gift(
            None,
            purchase.id,
            recipient.id,
            _faker.emoji(),
            _faker.text()
        )


def gen_products(
    publishers: List[Publisher],
    users: PositiveInt,
    n: PositiveInt
) -> Iterable[Product]:
    for i in range(n):
        yield Product(
            None,
            publishers[_faker.pyint(0, len(publishers)-1)].id,
            game_names[_faker.pyint(0, len(game_names)-1)],
            _faker.text(),
            _faker.pydecimal(max_value=5000, positive=True, right_digits=2),
            0,
            0,
            0
        )


def gen_publisher_user_bonds(
    all_publishers: List[Publisher],
    all_users: List[User],
    n: PositiveInt
) -> Iterable[PublisherUserBond]:
    for i in range(n):
        publisher = all_publishers[_faker.pyint(0, len(all_publishers)-1)]
        for user in rchoices(all_users, k=len(all_users)//2):
            if (publisher.id is None) or (user.id is None):
                raise NoneIdException()
            yield PublisherUserBond(
                None,
                publisher.id,
                user.id
            )


def gen_publishers(n: PositiveInt) -> Iterable[Publisher]:
    for i in range(n):
        yield Publisher(
            None,
            _faker.company(),
            _faker.bs()
        )


def gen_purchases(
    all_products: List[Product],
    all_users: List[User],
    max_products_per_user: PositiveInt
) -> Iterable[Purchase]:
    for user in all_users:
        products_per_user = randint(1, max_products_per_user)
        for product in rchoices(all_products, k=products_per_user):
            if (product.id is None) or (user.id is None):
                raise NoneIdException()
            yield Purchase(
                None,
                product.id,
                user.id,
                _faker.date(),
            )


@lru_cache()
def gen_tags() -> Iterable[Tag]:
    return tags
    html_text = requests.get('https://store.steampowered.com/tag/browse/#global_492').text
    html = BeautifulSoup(html_text, "lxml")
    return map(
        lambda x: Tag(x[0], x[1].text), # type: ignore
        enumerate(html.select('.tag_browse_tag'))
    )


def gen_assigned_tags(
    tags: List[Tag],
    products: List[Product],
    max_tags_per_product: PositiveInt
) -> Iterable[AssignedTag]:
    for p in rchoices(products, k=len(products)):
        for t in rchoices(tags, k=randint(1, max_tags_per_product)):
            if (t.id is None) or (p.id is None):
                raise Exception('id is None in gen')
            yield AssignedTag(None, t.id, p.id)


def gen_users(n: PositiveInt) -> Iterable[User]:
    for i in range(n):
        yield User(
            None,
            _faker.ascii_email(),
            _faker.password(),
            _faker.user_name(),
            _faker.pydecimal(max_value=10000, positive=True, right_digits=2)
        )


def gen_dependencies(
    products: List[Product],
    maxDlcPerGame: PositiveInt
) -> Iterable[ProductDependency]:
    used = []
    for required in rchoices(products, k=len(products)):
        used.append(required)
        for requested in rchoices(products, k=maxDlcPerGame):
            if requested in used:
                continue
            used.append(requested)
            yield ProductDependency(
                requested.id,
                required.id
            )
