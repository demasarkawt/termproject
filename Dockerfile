# Use official slim Python 3.11 image
FROM python:3.11-slim

# Set working directory inside the container
WORKDIR /app

# Copy only requirements first (for Docker layer caching)
COPY server/requirements.txt .

# Install dependencies
RUN pip install --no-cache-dir --break-system-packages -r requirements.txt

# Copy the entire server source code
COPY server/ .

# Railway injects $PORT — fallback to 8000 locally
CMD ["sh", "-c", "uvicorn main:app --host 0.0.0.0 --port ${PORT:-8000}"]
