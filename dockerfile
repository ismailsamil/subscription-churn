FROM python:3.12-slim
RUN export DOCKER_TLS_VERIFY=0

WORKDIR /app

COPY . /app

RUN pip install --no-cache-dir --upgrade pip && \
    pip install --no-cache-dir dbt-core