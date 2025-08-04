FROM rasa/rasa:3.6.2

WORKDIR /app
COPY . /app

USER root
RUN apt-get update && apt-get install -y curl
RUN mkdir -p models
RUN rasa train --config config/config.yml --domain domain.yml --data data --out models/

USER 1001
EXPOSE 5005

HEALTHCHECK --interval=30s --timeout=10s --start-period=40s --retries=3 \
    CMD curl -f http://localhost:5005/health || exit 1

CMD [ "run", "--enable-api", "--port", "5005", "--cors", "*", "--config", "config/config.yml", "--model", "models" ]
