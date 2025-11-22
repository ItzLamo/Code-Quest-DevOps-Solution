# Multi-stage build for Python Vote service
FROM python:3.11-slim AS base

# Create non-root user
RUN groupadd -r vote && useradd -r -g vote vote

# Set working directory
WORKDIR /app

# Install dependencies in a separate layer
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

# Copy application code
COPY . .

# Change ownership to non-root user
RUN chown -R vote:vote /app

# Switch to non-root user
USER vote

# Expose port
EXPOSE 5000

# Health check
HEALTHCHECK --interval=30s --timeout=3s --start-period=10s --retries=3 \
  CMD python -c "import requests; requests.get('http://localhost:5000', timeout=2)"

# Run application
CMD ["gunicorn", "app:app", "-b", "0.0.0.0:5000", "--log-file", "-", "--access-logfile", "-", "--workers", "4", "--keep-alive", "0"]


