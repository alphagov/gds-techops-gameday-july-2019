FROM python:3

WORKDIR /app
COPY requirements.txt ./
RUN pip install --no-cache-dir -r requirements.txt

COPY . .

ENTRYPOINT [ "/usr/local/bin/locust", \
        "--locustfile=/app/locust.py", \
        "--clients=1", \
        "--hatch-rate=1", \
        "--no-web", \
        "--host" ]
CMD []
