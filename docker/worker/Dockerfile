# Multi-stage build for .NET Worker service
FROM mcr.microsoft.com/dotnet/sdk:7.0 AS build

WORKDIR /app

# Copy csproj and restore dependencies
COPY *.csproj .
RUN dotnet restore

# Copy source and build
COPY . .
RUN dotnet publish -c Release -o out

# Runtime stage
FROM mcr.microsoft.com/dotnet/runtime:7.0-alpine

# Install security updates
RUN apk --no-cache upgrade

# Create non-root user
RUN addgroup -S worker && adduser -S worker -G worker

WORKDIR /app

# Copy build output
COPY --from=build /app/out .

# Change ownership
#RUN chown -R worker:worker /app

# Switch to non-root user
#USER worker

# Health check
HEALTHCHECK --interval=30s --timeout=3s --start-period=15s --retries=3 \
  CMD pgrep -f dotnet || exit 1

# Run application
CMD ["/usr/bin/dotnet", "/app/Worker.dll"]
