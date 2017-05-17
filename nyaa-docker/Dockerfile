FROM python:3.6.1

ADD requirements.txt /root/

RUN pip install -r /root/requirements.txt

ADD *.py /app/
ADD *.sh /app/
ADD es_mapping.yml /app/

VOLUME /app/nyaa

ENTRYPOINT ["python", "/app/run.py"]