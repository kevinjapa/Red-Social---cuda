
FROM nvidia/cuda:12.4.1-cudnn-devel-ubuntu22.04

RUN apt-get -qq update && \
    apt-get -qq install -y build-essential python3 python3-pip python3-dev && \
    apt-get clean && rm -rf /var/lib/apt/lists/*

COPY requirements.txt /app/requirements.txt
WORKDIR /app
RUN pip3 install --no-cache-dir -r requirements.txt

COPY . .

RUN mkdir -p static/uploads static/processed

EXPOSE 5001

CMD ["python3", "app.py"]