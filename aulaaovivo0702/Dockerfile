FROM gcr.io/distroless/python3-debian12:nonroot

WORKDIR /app

# RUN apt-get update && apt-get install -y python3 python3-pip

COPY  app/main.py .
ENTRYPOINT [ "python", "main.py" ]