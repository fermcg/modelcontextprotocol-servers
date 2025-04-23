# Build base image first (using build-only profile)
docker compose --profile build-only build

# Stop any running containers
docker compose --profile default down

# Start all default services
docker compose --profile default up -d

# Alternatively, to start ALL services including non-default ones:
docker compose --profile all up -d
