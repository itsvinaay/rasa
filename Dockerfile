FROM rasa/rasa:3.6.2

# Switch to root to install packages
USER root

# Install curl for healthcheck
RUN apt-get update && \
    apt-get install -y curl && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

WORKDIR /app

# Copy only necessary files
COPY config/ /app/config/
COPY data/ /app/data/
COPY domain.yml /app/domain.yml

# Create models directory and ensure correct permissions
RUN mkdir -p /app/models && \
    chown -R 1001:root /app && \
    chmod -R g+rwX /app

# Train the model with explicit paths
RUN rasa train \
    --domain domain.yml \
    --data data \
    --config config/config.yml \
    --out models \
    --fixed-model-name model.tar.gz

# Switch back to non-root user
USER 1001

EXPOSE 5005

# More robust healthcheck
HEALTHCHECK --interval=30s --timeout=10s --start-period=60s --retries=5 \
    CMD curl -f http://localhost:5005/health || exit 1

# Start Rasa server with explicit model path
CMD [ "run", \
      "--enable-api", \
      "--port", "5005", \
      "--cors", "*", \
      "--model", "/app/models/model.tar.gz" ]
