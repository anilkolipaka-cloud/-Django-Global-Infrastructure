FROM python:3.11-slim

WORKDIR /app

# Ensure output is unbuffered so Cloud Run can stream logs
ENV PYTHONUNBUFFERED=1

COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

COPY . .

# Run the Django application with Gunicorn
# Using port 8080 as this is the default for Cloud Run
CMD ["gunicorn", "--bind", "0.0.0.0:8080", "--workers", "2", "project.wsgi:application"]
