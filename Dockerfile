# Stage 1: Build dependencies
FROM python:3.12-alpine AS pybuilder

# Copy dependency files
ADD pyproject.toml pdm.lock /build/
WORKDIR /build

# Install build tools and dependencies
RUN apk add --no-cache alpine-sdk python3-dev musl-dev linux-headers \
    && pip install pdm \
    && pdm install --prod

# Stage 2: Application runtime
FROM python:3.12-alpine AS runner

# Set working directory
WORKDIR /app

# Install runtime dependencies
RUN apk add --no-cache ffmpeg aria2

# Copy only the necessary files
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

# Copy Python virtual environment from the build stage
COPY --from=pybuilder /build/.venv/lib/ /usr/local/lib/

# Copy source code
COPY src /app

# Set working directory
WORKDIR /app

# Default command
CMD ["python", "main.py"]
