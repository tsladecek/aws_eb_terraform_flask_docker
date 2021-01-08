FROM ubuntu:18.04

ENV LANG C.UTF-8

RUN apt-get update && \
    apt-get install -y python3-pip python3-dev

COPY . /application
WORKDIR /application

RUN pip3 install -r requirements.txt

EXPOSE 80

ENTRYPOINT ["python3"]

CMD ["application.py"]
