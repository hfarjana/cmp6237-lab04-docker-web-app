FROM python@sha256:e06cc1111ed84189e91866447f562b89faadbfbbb9937cd67e6bf4172cdb45df

WORKDIR /home/myapp

COPY requirements.txt .

RUN python -m pip install --no-cache-dir -r requirements.txt

COPY app/sample_app.py .
COPY app/templates ./templates
COPY app/static ./static

EXPOSE 5000

CMD ["python", "sample_app.py"]
