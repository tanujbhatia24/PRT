# Use an official lightweight Python image
FROM python:3.11-slim


# Security: create a non-root user
RUN useradd --create-home --shell /bin/bash appuser
WORKDIR /home/appuser/app


# Install dependencies
COPY requirements.txt ./
RUN pip install --no-cache-dir -r requirements.txt


# Copy app
COPY app.py ./


# Change ownership to non-root user
RUN chown -R appuser:appuser /home/appuser/app
USER appuser


# Expose the port the app runs on
EXPOSE 5000


# Use a simple entrypoint
CMD ["python", "app.py"]