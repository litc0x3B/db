from typing import ClassVar, Optional
from decimal import Decimal
from datetime import datetime
from dataclasses import dataclass
from enum import Enum

class Role(Enum):
    USER = 0
    ADMIN = 1
    BANNED = 2


def to_str_value(x):
    if isinstance(x, str):
        return "'" + x.replace("'", "''") + "'"
    elif isinstance(x, datetime):
        return "'" + str(x) + "'"
    elif isinstance(x, bytes):
        return f"decode('{x.hex()}', 'hex')"
    elif isinstance(x, Role):
        return to_str_value(x.name.lower())
    elif x is None:
        return 'NULL'
    else:
        return str(x)

class Data:
    table_name: ClassVar[str]
    id_field_name: ClassVar[Optional[str]]


@dataclass
class User(Data):
    id_user: Optional[int]
    
    username: str
    registration_time: datetime
    login: str
    password_hash: bytes
    profile_pic_url: str
    role: Role

    table_name = '"user"'
    id_field_name = 'id_user'
    
@dataclass
class Image(Data):
    id_image: Optional[int]
    
    url: str
    created_at: datetime
    source_url: Optional[str]
    image_width: int
    image_height: int
    
    id_user: int
    
    table_name = 'image'
    id_field_name = 'id_image'
    
@dataclass
class Comment(Data):
    id_comment: Optional[int]
    
    content: str
    created_at: datetime

    id_user: int
    id_image: int
    
    table_name = 'comment'
    id_field_name = 'id_comment'
    
@dataclass 
class FavoriteUserImage(Data):
    id_user: int
    id_image: int
    
    created_at: datetime
    
    table_name = 'favorite_user_image'
    id_field_name = None
    
@dataclass
class Tag(Data):
    id_tag: Optional[int]
    
    name: str
    description_page_url: str
    
    id_tag_category: int
    
    table_name = 'tag'
    id_field_name = 'id_tag'
    
@dataclass
class TagCategory:
    id_tag_category: Optional[int]
    
    name: str
    description_page_url: str
    
    table_name = 'tag_category'
    id_field_name = 'id_tag_category'

@dataclass
class ImageTag:
    id_image: int
    id_tag: int
    
    table_name = 'image_tag'
    id_field_name = None
    
    def __hash__(self):
        return hash((self.id_image, self.id_tag))