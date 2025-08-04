FROM rasa/rasa:3.6.2

WORKDIR /app
COPY . /app

USER root
RUN rasa train

USER 1001
EXPOSE 5005

CMD [ "run", "--enable-api", "--port", "5005", "--cors", "*" ]
