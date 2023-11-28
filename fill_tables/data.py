from typing import ClassVar, Optional
from decimal import Decimal
from datetime import date
from dataclasses import dataclass


class Data:
    table_name: ClassVar[str]


@dataclass
class Publisher(Data):
    id: Optional[int]
    name: str
    description: str

    table_name: ClassVar[str] = 'Publisher'


@dataclass
class PublisherUserBond(Data):
    id: Optional[int]
    publisher_id: int
    user_id: int

    table_name: ClassVar[str] = 'Publisher_User'

@dataclass
class Gift(Data):
    id: Optional[int]
    purchase_id: int
    recipient_id: int
    title: str
    message: str
    
    table_name: ClassVar[str] = 'gift'


@dataclass
class Product(Data):
    id: Optional[int]
    publisher_id: int
    name: str
    description: str
    price: Decimal
    purchasers_count: int
    reviews_count: int
    rating_sum: int

    table_name: ClassVar[str] = 'Product'


@dataclass
class Purchase(Data):
    id: Optional[int]
    product_id: int
    buyer_id: int
    date: date

    table_name: ClassVar[str] = 'Purchase'


@dataclass
class Tag(Data):
    id: Optional[int]
    name: str

    table_name: ClassVar[str] = 'Tag'


@dataclass
class AssignedTag(Data):
    id: Optional[int]
    tag_id: int
    product_id: int

    table_name: ClassVar[str] = 'AssignedTag'


@dataclass
class User(Data):
    id: Optional[int]
    email: str
    password: str
    username: str
    money: Decimal
    
    table_name: ClassVar[str] = '"User"'


@dataclass
class Review(Data):
    id: Optional[int]
    subject_id: int
    writer_id: int
    text: str
    rating: int
    date: date

    table_name: ClassVar[str] = 'Review'


@dataclass
class Achievement:
    id: Optional[int]
    product_id: int
    name: str
    achievers_count: int

    table_name: ClassVar[str] = 'Achievement'


@dataclass
class ObtainedAchievement:
    id: Optional[int]
    user_id: int
    achievement_id: int

    table_name: ClassVar[str] = 'ObtainedAchievement'
