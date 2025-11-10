FROM python:3.11-slim AS backend
WORKDIR /app
COPY ./server/requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt
COPY ./server ./server
RUN cd ./server \
    && rm -rf migrations \
    && flask db init \
    && flask db migrate -m "Initial migration." \
    && flask db upgrade \
    && flask init-db

FROM node:18-alpine AS frontend
WORKDIR /app
COPY ./client .
RUN npm install

FROM ubuntu:22.04
WORKDIR /app

RUN apt update && apt install -y curl
RUN curl -fsSL https://deb.nodesource.com/setup_18.x | bash -
RUN apt install -y nodejs 
RUN apt install -y python3-pip

COPY --from=backend /app /app
COPY --from=frontend /app ./client

RUN pip install --no-cache-dir -r ./server/requirements.txt

COPY ./start.sh .
RUN chmod +x start.sh


ENTRYPOINT [ "./start.sh" ]

EXPOSE 3000