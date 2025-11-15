"""
Init file for page_objects package
"""
from .base_page import BasePage
from .login_page import LoginPage
from .register_page import RegisterPage
from .register_detail_page import RegisterDetailPage

__all__ = [
    'BasePage',
    'LoginPage',
    'RegisterPage',
    'RegisterDetailPage',
]
