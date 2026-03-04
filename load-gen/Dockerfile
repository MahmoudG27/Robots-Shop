FROM python:3.9-slim

WORKDIR /load

COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

COPY entrypoint.sh .
COPY robot-shop.py .

RUN chmod +x entrypoint.sh

CMD ["./entrypoint.sh"]