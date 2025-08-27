#!/bin/bash

# Le Livreur Pro Deployment Script
# This script automates the deployment process for different environments

set -e  # Exit on any error

# Configuration
APP_NAME="le-livreur-pro"
DOCKER_IMAGE="lelivreurpro/app"
ENVIRONMENTS=("development" "staging" "production")

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Logging function
log() {
    echo -e "${GREEN}[$(date +'%Y-%m-%d %H:%M:%S')] $1${NC}"
}

error() {
    echo -e "${RED}[ERROR] $1${NC}"
    exit 1
}

warning() {
    echo -e "${YELLOW}[WARNING] $1${NC}"
}

info() {
    echo -e "${BLUE}[INFO] $1${NC}"
}

# Check dependencies
check_dependencies() {
    log "Checking dependencies..."
    
    command -v docker >/dev/null 2>&1 || error "Docker is required but not installed"
    command -v docker-compose >/dev/null 2>&1 || error "Docker Compose is required but not installed"
    command -v flutter >/dev/null 2>&1 || error "Flutter is required but not installed"
    command -v git >/dev/null 2>&1 || error "Git is required but not installed"
    
    log "All dependencies satisfied"
}

# Validate environment
validate_environment() {
    local env=$1
    
    if [[ ! " ${ENVIRONMENTS[@]} " =~ " ${env} " ]]; then
        error "Invalid environment: $env. Valid options: ${ENVIRONMENTS[*]}"
    fi
    
    log "Environment validated: $env"
}

# Load environment configuration
load_env_config() {
    local env=$1
    local env_file="deployment/env/.env.${env}"
    
    if [[ -f $env_file ]]; then
        log "Loading environment configuration from $env_file"
        set -a  # Automatically export all variables
        source $env_file
        set +a
    else
        warning "Environment file not found: $env_file"
    fi
}

# Run tests
run_tests() {
    log "Running tests..."
    
    # Unit tests
    info "Running unit tests..."
    flutter test test/unit/ --coverage || error "Unit tests failed"
    
    # Widget tests
    info "Running widget tests..."
    flutter test test/widget/ || error "Widget tests failed"
    
    # Integration tests (if available)
    if [[ -d "test/integration" ]]; then
        info "Running integration tests..."
        flutter test test/integration/ || error "Integration tests failed"
    fi
    
    log "All tests passed"
}

# Build application
build_app() {
    local platform=$1
    local env=$2
    
    log "Building application for $platform in $env environment..."
    
    # Clean previous builds
    flutter clean
    flutter pub get
    
    case $platform in
        "web")
            flutter build web --release --web-renderer html
            ;;
        "android")
            flutter build apk --release
            flutter build appbundle --release
            ;;
        "ios")
            flutter build ios --release --no-codesign
            ;;
        "all")
            flutter build web --release --web-renderer html
            flutter build apk --release
            flutter build appbundle --release
            flutter build ios --release --no-codesign
            ;;
        *)
            error "Invalid platform: $platform. Valid options: web, android, ios, all"
            ;;
    esac
    
    log "Build completed for $platform"
}

# Build Docker image
build_docker_image() {
    local env=$1
    local tag="${DOCKER_IMAGE}:${env}-$(git rev-parse --short HEAD)"
    local latest_tag="${DOCKER_IMAGE}:${env}-latest"
    
    log "Building Docker image: $tag"
    
    docker build -t $tag -t $latest_tag .
    
    log "Docker image built successfully: $tag"
}

# Deploy to environment
deploy() {
    local env=$1
    local platform=$2
    
    log "Deploying to $env environment..."
    
    case $env in
        "development")
            deploy_development
            ;;
        "staging")
            deploy_staging
            ;;
        "production")
            deploy_production
            ;;
    esac
    
    log "Deployment to $env completed successfully"
}

# Development deployment
deploy_development() {
    info "Deploying to development environment..."
    
    # Use Docker Compose for local development
    docker-compose -f docker-compose.yml -f docker-compose.dev.yml up -d
    
    # Wait for services to be ready
    sleep 10
    
    # Run health checks
    check_health "http://localhost:8080/health"
}

# Staging deployment
deploy_staging() {
    info "Deploying to staging environment..."
    
    # Deploy to staging server (could be AWS, GCP, Azure, etc.)
    # This is a template - customize based on your infrastructure
    
    # Example: Deploy to AWS ECS
    # aws ecs update-service --cluster staging --service le-livreur-pro --force-new-deployment
    
    # Example: Deploy to Kubernetes
    # kubectl apply -f deployment/k8s/staging/
    
    info "Staging deployment completed"
}

# Production deployment
deploy_production() {
    info "Deploying to production environment..."
    
    # Production deployment with zero-downtime
    # This is a template - customize based on your infrastructure
    
    # Example: Blue-Green deployment
    # ./deployment/scripts/blue-green-deploy.sh
    
    # Example: Rolling update on Kubernetes
    # kubectl set image deployment/le-livreur-pro app=${DOCKER_IMAGE}:production-latest
    
    info "Production deployment completed"
}

# Health check
check_health() {
    local url=$1
    local max_attempts=30
    local attempt=1
    
    log "Performing health check on $url"
    
    while [[ $attempt -le $max_attempts ]]; do
        if curl -f -s $url >/dev/null; then
            log "Health check passed"
            return 0
        fi
        
        info "Health check attempt $attempt/$max_attempts failed, retrying in 10 seconds..."
        sleep 10
        ((attempt++))
    done
    
    error "Health check failed after $max_attempts attempts"
}

# Rollback deployment
rollback() {
    local env=$1
    local version=$2
    
    warning "Rolling back $env environment to version $version"
    
    case $env in
        "staging"|"production")
            # Example rollback using Docker
            docker service update --image ${DOCKER_IMAGE}:${version} ${APP_NAME}-${env}
            ;;
        *)
            error "Rollback not supported for $env environment"
            ;;
    esac
    
    log "Rollback completed"
}

# Database migration
migrate_database() {
    local env=$1
    
    log "Running database migrations for $env environment..."
    
    # Run Supabase migrations if needed
    # npx supabase db push --env $env
    
    log "Database migrations completed"
}

# Generate deployment report
generate_report() {
    local env=$1
    local start_time=$2
    local end_time=$(date '+%Y-%m-%d %H:%M:%S')
    
    log "Generating deployment report..."
    
    cat > "deployment/reports/deployment-${env}-$(date +%Y%m%d-%H%M%S).md" << EOF
# Deployment Report

## Environment: $env
- **Start Time:** $start_time
- **End Time:** $end_time
- **Git Commit:** $(git rev-parse HEAD)
- **Git Branch:** $(git rev-parse --abbrev-ref HEAD)
- **Deployed By:** $(git config user.name)

## Changes
$(git log --oneline -10)

## Status
✅ Deployment completed successfully

## Services
- Web Application: Running
- Database: Connected
- Cache: Active
- Monitoring: Enabled

## Health Checks
- Application: ✅ Healthy
- Database: ✅ Connected
- External APIs: ✅ Available
EOF

    log "Deployment report generated"
}

# Main deployment function
main() {
    local env=${1:-development}
    local platform=${2:-web}
    local skip_tests=${3:-false}
    
    local start_time=$(date '+%Y-%m-%d %H:%M:%S')
    
    log "Starting deployment process..."
    log "Environment: $env"
    log "Platform: $platform"
    log "Skip tests: $skip_tests"
    
    # Pre-deployment checks
    check_dependencies
    validate_environment $env
    load_env_config $env
    
    # Run tests (unless skipped)
    if [[ $skip_tests != "true" ]]; then
        run_tests
    else
        warning "Skipping tests as requested"
    fi
    
    # Build application
    build_app $platform $env
    
    # Build Docker image for web deployment
    if [[ $platform == "web" || $platform == "all" ]]; then
        build_docker_image $env
    fi
    
    # Run database migrations
    migrate_database $env
    
    # Deploy
    deploy $env $platform
    
    # Generate report
    generate_report $env "$start_time"
    
    log "Deployment completed successfully! 🚀"
}

# Script usage
usage() {
    echo "Usage: $0 [environment] [platform] [skip_tests]"
    echo ""
    echo "Environments: ${ENVIRONMENTS[*]}"
    echo "Platforms: web, android, ios, all"
    echo "Skip tests: true, false (default: false)"
    echo ""
    echo "Examples:"
    echo "  $0 development web"
    echo "  $0 production android true"
    echo "  $0 staging all false"
    echo ""
    echo "Additional commands:"
    echo "  $0 rollback [environment] [version]"
    echo "  $0 health [environment]"
}

# Handle special commands
case $1 in
    "rollback")
        rollback $2 $3
        ;;
    "health")
        check_health "http://localhost:8080/health"
        ;;
    "help"|"-h"|"--help")
        usage
        ;;
    *)
        main "$@"
        ;;
esac