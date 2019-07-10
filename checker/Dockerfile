FROM python
LABEL maintainer="gehaxelt"

# Install python3 and uswgi
RUN apt-get update -y
RUN apt-get install -y nginx git

# use python3
RUN pip3 install uwsgi

# copy our files in.
WORKDIR /checker
COPY ./requirements.txt /checker/requirements.txt
RUN pip3 install -r requirements.txt
COPY . .



ENTRYPOINT [ "uwsgi", "--uid", "uwsgi", \
               "--socket", "[::]:3031", \
               "--protocol", "http", \
               "--ini", "/checker/uwsgi.ini" ]
