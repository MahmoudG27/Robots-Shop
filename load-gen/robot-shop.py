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
        headers = {'x-forwarded-for': fake_ip}

        try:
            # Home
            self.client.get('/', headers=headers)

            # Unique ID
            res = self.client.get('/api/user/uniqueid', headers=headers)

            if res.status_code != 200:
                print(f'Unique ID failed: {res.status_code}')
                return

            try:
                user_data = res.json()
                uniqueid = user_data.get('uuid') or user_data.get('name') or 'anonymous'
            except Exception:
                uniqueid = res.text if res.text else 'anonymous'

            # Categories
            self.client.get('/api/catalogue/categories', headers=headers)

            # Products
            res = self.client.get('/api/catalogue/products', headers=headers)

            if res.status_code != 200:
                print(f'Products failed: {res.status_code}')
                return

            try:
                products = res.json()
            except Exception:
                print('Invalid products JSON')
                return

            if not products:
                print('No products found')
                return

            in_stock_products = [
                p for p in products if p.get('instock', 0) > 0
            ]

            if not in_stock_products:
                print('No in-stock products')
                return

            # Shopping flow
            for _ in range(2):
                item = choice(in_stock_products)

                if randint(1, 10) <= 3:
                    self.client.put(
                        f'/api/ratings/api/rate/{item["sku"]}/{randint(1,5)}',
                        headers=headers
                    )

                self.client.get(
                    f'/api/catalogue/product/{item["sku"]}',
                    headers=headers
                )

                self.client.get(
                    f'/api/ratings/api/fetch/{item["sku"]}',
                    headers=headers
                )

                self.client.get(
                    f'/api/cart/add/{uniqueid}/{item["sku"]}/2',
                    headers=headers
                )

            # Cart
            res = self.client.get(
                f'/api/cart/cart/{uniqueid}',
                headers=headers
            )

            if res.status_code != 200:
                return

            cart = res.json()

            if cart.get('items'):
                item = choice(cart['items'])

                self.client.get(
                    f'/api/cart/add/{uniqueid}/{item["sku"]}/2',
                    headers=headers
                )

            # Shipping
            res = self.client.get('/api/shipping/codes', headers=headers)

            if res.status_code != 200:
                return

            codes = res.json()

            if not codes:
                return

            code = choice(codes)

            res = self.client.get(
                f'/api/shipping/cities/{code["code"]}',
                headers=headers
            )

            if res.status_code != 200:
                return

            cities = res.json()

            if not cities:
                print(f'No cities for {code["code"]}')
                return

            city = choice(cities)
            city_id = city.get('id') or city.get('city_id')

            if not city_id:
                return

            # Calculate shipping
            res = self.client.get(
                f'/api/shipping/calc/{city_id}',
                headers=headers
            )

            if res.status_code != 200:
                return

            shipping = res.json()

            shipping['location'] = f'{code["name"]} {city["name"]}'

            # Confirm shipping
            res = self.client.post(
                f'/api/shipping/confirm/{uniqueid}',
                json=shipping,
                headers=headers
            )

            if res.status_code != 200:
                return

            cart = res.json()

            # Payment
            res = self.client.post(
                f'/api/payment/pay/{uniqueid}',
                json=cart,
                headers=headers
            )

            print(f'Payment status: {res.status_code}')

        except Exception as e:
            print(f'Unexpected error in load task: {e}')

    @task
    def error(self):
        if os.environ.get('ERROR') == '1':
            cart = {'total': 0, 'tax': 0}
            self.client.post('/api/payment/pay/partner-57', json=cart)