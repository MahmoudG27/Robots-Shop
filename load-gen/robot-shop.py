import os
import random

from locust import HttpUser, task, between
from random import choice, randint


class UserBehavior(HttpUser):
    wait_time = between(0.5, 2)

    fake_ip_addresses = [
        "156.33.241.5",
        "34.196.93.245",
        "98.142.103.241",
        "192.241.230.151",
        "46.114.35.116",
        "52.77.99.130",
        "60.242.161.215"
    ]

    def on_start(self):
        print('Starting user session')

    @task
    def login(self):
        fake_ip = random.choice(self.fake_ip_addresses)
        credentials = {
            'name': 'user',
            'password': 'password'
        }
        res = self.client.post(
            '/api/user/login',
            json=credentials,
            headers={'x-forwarded-for': fake_ip}
        )
        print('login {}'.format(res.status_code))

    @task
    def load(self):
        fake_ip = random.choice(self.fake_ip_addresses)
        self.client.get('/', headers={'x-forwarded-for': fake_ip})

        user_res = self.client.get(
            '/api/user/uniqueid',
            headers={'x-forwarded-for': fake_ip}
        ).json()

        uniqueid = user_res.get('uuid') or user_res.get('name') or 'anonymous'

        self.client.get('/api/catalogue/categories', headers={'x-forwarded-for': fake_ip})

        products = self.client.get(
            '/api/catalogue/products',
            headers={'x-forwarded-for': fake_ip}
        ).json()

        for i in range(2):
            item = None
            while True:
                item = choice(products)
                if item['instock'] != 0:
                    break

            if randint(1, 10) <= 3:
                self.client.put(
                    f'/api/ratings/api/rate/{item["sku"]}/{randint(1, 5)}',
                    headers={'x-forwarded-for': fake_ip}
                )

            self.client.get(f'/api/catalogue/product/{item["sku"]}', headers={'x-forwarded-for': fake_ip})
            self.client.get(f'/api/ratings/api/fetch/{item["sku"]}', headers={'x-forwarded-for': fake_ip})
            self.client.get(f'/api/cart/add/{uniqueid}/{item["sku"]}/1', headers={'x-forwarded-for': fake_ip})

        cart = self.client.get(
            f'/api/cart/cart/{uniqueid}',
            headers={'x-forwarded-for': fake_ip}
        ).json()

        if cart.get('items'):
            item = choice(cart['items'])
            self.client.get(
                f'/api/cart/update/{uniqueid}/{item["sku"]}/2',
                headers={'x-forwarded-for': fake_ip}
            )
        else:
            print(f'Cart empty for user {uniqueid}')

        code = choice(self.client.get('/api/shipping/codes').json())
        
        cities_res = self.client.get(f'/api/shipping/cities/{code["code"]}').json()
        
        if len(cities_res) > 0:
            city = choice(cities_res)
            city_id = city.get('id') or city.get('city_id') 

            shipping = self.client.get(
                f'/api/shipping/calc/{city_id}'
            ).json()

            shipping['location'] = f'{code["name"]} {city["name"]}'

            cart = self.client.post(
                f'/api/shipping/confirm/{uniqueid}',
                json=shipping
            ).json()

            order = self.client.post(
                f'/api/payment/pay/{uniqueid}',
                json=cart
            ).json()

            print('Order {}'.format(order))
        else:
            print(f'No cities found for {code["code"]}')

    @task
    def error(self):
        if os.environ.get('ERROR') == '1':
            cart = {'total': 0, 'tax': 0}
            self.client.post('/api/payment/pay/partner-57', json=cart)