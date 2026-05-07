FROM python:3.9-slim

WORKDIR /load

RUN apt-get update && apt-get install -y \
    build-essential \
    gcc \
    libffi-dev \
    libev-dev \
    && rm -rf /var/lib/apt/lists/*

COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

COPY entrypoint.sh .
COPY robot-shop.py .

RUN chmod +x entrypoint.sh

CMD ["./entrypoint.sh"]