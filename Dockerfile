FROM rasa/rasa:3.6.2

WORKDIR /app
COPY . /app

USER root
RUN apt-get update && apt-get install -y curl

# Create required directories and copy config files
RUN mkdir -p models

# Train the model
RUN rasa train \
    --domain domain.yml \
    --data data \
    --config config/config.yml \
    --out models \
    --fixed-model-name model.tar.gz

USER 1001
EXPOSE 5005

HEALTHCHECK --interval=30s --timeout=10s --start-period=40s --retries=3 \
    CMD curl -f http://localhost:5005/health || exit 1

CMD [ "run", "--enable-api", "--port", "5005", "--cors", "*", "--model", "models/model.tar.gz" ]
