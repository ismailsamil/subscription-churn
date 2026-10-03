FROM python:3.12-slim

RUN apt-get update && \
    apt-get install -y ca-certificates

COPY company-ca.crt /usr/local/share/ca-certificates/company-ca.crt

RUN update-ca-certificates

WORKDIR /app

COPY . .

CMD ["python", "app.py"]