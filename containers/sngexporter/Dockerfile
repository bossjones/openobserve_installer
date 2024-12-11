FROM python:3.11

COPY sng_exporter.py /app/sng_exporter.py
WORKDIR /app
# ENTRYPOINT ["python3", "/app/sng_exporter.py"]
ENTRYPOINT ["tail", "-f", "/dev/null"]
