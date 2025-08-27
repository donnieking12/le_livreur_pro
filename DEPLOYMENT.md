# Le Livreur Pro - Deployment Guide

## Overview

This guide covers the complete deployment process for the Le Livreur Pro delivery platform, designed specifically for the Côte d'Ivoire market. The application supports multiple deployment environments and provides comprehensive CI/CD automation.

## Architecture

### Technology Stack

- **Frontend**: Flutter Web (Multi-platform support)
- **Backend**: Supabase (PostgreSQL + Real-time)
- **Authentication**: Supabase Auth with phone-based OTP
- **Payments**: Orange Money, MTN Money, Moov Money, Wave, Cards
- **Maps**: Google Maps Platform
- **Notifications**: Firebase Cloud Messaging
- **State Management**: Riverpod
- **Localization**: Easy Localization (French/English)

### Infrastructure Components

- **Web Application**: Nginx + Flutter Web
- **Database**: PostgreSQL (via Supabase)
- **Cache**: Redis
- **Monitoring**: Prometheus + Grafana
- **Logging**: ELK Stack (Elasticsearch, Logstash, Kibana)
- **Container Orchestration**: Docker + Kubernetes
- **Load Balancing**: Nginx Load Balancer
- **SSL/TLS**: Let's Encrypt certificates

## Environments

### 1. Development

- **Purpose**: Local development and testing
- **URL**: http://localhost:8080
- **Features**: Hot reload, dev tools, mock APIs
- **Database**: Local PostgreSQL or Supabase development project

### 2. Staging

- **Purpose**: Pre-production testing and QA
- **URL**: https://staging.lelivreurpro.ci
- **Features**: Production-like environment with test data
- **Database**: Staging Supabase project

### 3. Production

- **Purpose**: Live application for end users
- **URL**: https://lelivreurpro.ci
- **Features**: Full production features, monitoring, scaling
- **Database**: Production Supabase project

## Prerequisites

### Required Software

1. **Flutter SDK** (3.19.0 or later)
2. **Docker** (20.10+ with Docker Compose)
3. **Node.js** (18+ for build tools)
4. **Git** (for version control)
5. **kubectl** (for Kubernetes deployments)

### Required Accounts & Services

1. **Supabase** - Database and real-time features
2. **Google Cloud Platform** - Maps API
3. **Firebase** - Push notifications
4. **Payment Gateways** - Orange Money, MTN Money, etc.
5. **Domain Registration** - For production domain
6. **SSL Certificate** - Let's Encrypt or commercial

## Environment Setup

### 1. Clone Repository

```bash
git clone https://github.com/your-org/le-livreur-pro.git
cd le-livreur-pro
```

### 2. Install Dependencies

```bash
flutter pub get
```

### 3. Configure Environment Variables

Copy and customize environment files:

```bash
cp deployment/env/.env.development.example deployment/env/.env.development
cp deployment/env/.env.production.example deployment/env/.env.production
```

Fill in your actual API keys and configuration values.

### 4. Setup Supabase

1. Create a new Supabase project
2. Configure authentication settings
3. Set up database schema
4. Enable real-time features
5. Configure row-level security (RLS)

## Deployment Methods

### Method 1: Automated Deployment Script

#### Quick Start

```bash
# Make deployment script executable
chmod +x deployment/deploy.sh

# Deploy to development
./deployment/deploy.sh development web

# Deploy to staging
./deployment/deploy.sh staging web

# Deploy to production
./deployment/deploy.sh production web
```

#### Advanced Usage

```bash
# Deploy specific platform
./deployment/deploy.sh production android

# Skip tests (not recommended for production)
./deployment/deploy.sh staging web true

# Rollback deployment
./deployment/deploy.sh rollback production v1.0.0

# Health check
./deployment/deploy.sh health production
```

### Method 2: Docker Deployment

#### Development with Docker Compose

```bash
# Start all services
docker-compose up -d

# View logs
docker-compose logs -f

# Stop services
docker-compose down
```

#### Production Docker Deployment

```bash
# Build production image
docker build -t lelivreurpro/app:production .

# Run with production configuration
docker run -d \
  --name le-livreur-pro \
  --env-file deployment/env/.env.production \
  -p 80:80 \
  -p 443:443 \
  lelivreurpro/app:production
```

### Method 3: Kubernetes Deployment

#### Prerequisites

```bash
# Install kubectl and configure cluster access
kubectl cluster-info

# Install ingress controller
kubectl apply -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/controller-v1.8.1/deploy/static/provider/cloud/deploy.yaml

# Install cert-manager for SSL
kubectl apply -f https://github.com/cert-manager/cert-manager/releases/download/v1.13.0/cert-manager.yaml
```

#### Deploy to Kubernetes

```bash
# Apply all manifests
kubectl apply -f deployment/k8s/production/

# Check deployment status
kubectl get pods -n le-livreur-pro
kubectl get services -n le-livreur-pro
kubectl get ingress -n le-livreur-pro

# View logs
kubectl logs -f deployment/le-livreur-app -n le-livreur-pro
```

### Method 4: CI/CD Pipeline

#### GitHub Actions Setup

1. Configure repository secrets in GitHub:

   - `ANDROID_KEYSTORE_BASE64`
   - `KEYSTORE_PASSWORD`
   - `KEY_ALIAS`
   - `KEY_PASSWORD`
   - `GOOGLE_PLAY_SERVICE_ACCOUNT_JSON`
   - `APP_STORE_CONNECT_API_KEY`
   - `SLACK_WEBHOOK`

2. Push to main branch to trigger deployment:

```bash
git push origin main
```

#### Manual Workflow Trigger

```bash
# Trigger deployment workflow
gh workflow run ci_cd.yml
```

## Platform-Specific Deployments

### Web Deployment

```bash
# Build for web
flutter build web --release --web-renderer html

# Deploy to web server
rsync -avz build/web/ user@server:/var/www/lelivreurpro/
```

### Android Deployment

```bash
# Build APK
flutter build apk --release

# Build App Bundle for Play Store
flutter build appbundle --release

# Sign and upload to Google Play Console
```

### iOS Deployment

```bash
# Build for iOS
flutter build ios --release

# Archive and upload to App Store Connect
# (Requires Xcode and Apple Developer account)
```

## Configuration Management

### Environment Variables

Key configuration files:

- `deployment/env/.env.development`
- `deployment/env/.env.staging`
- `deployment/env/.env.production`

### Critical Configuration

1. **Supabase URLs and Keys**
2. **Google Maps API Key**
3. **Payment Gateway Credentials**
4. **Firebase Configuration**
5. **SSL Certificates**
6. **Database Connection Strings**

### Security Best Practices

1. Never commit secrets to version control
2. Use environment-specific configurations
3. Rotate API keys regularly
4. Enable rate limiting
5. Configure proper CORS policies
6. Use HTTPS everywhere
7. Implement proper authentication

## Monitoring and Logging

### Health Checks

```bash
# Application health
curl https://lelivreurpro.ci/health

# Database connectivity
curl https://lelivreurpro.ci/api/health/db

# External services
curl https://lelivreurpro.ci/api/health/external
```

### Monitoring Dashboards

- **Application**: http://monitoring.lelivreurpro.ci:3000
- **Logs**: http://logs.lelivreurpro.ci:5601
- **Metrics**: http://metrics.lelivreurpro.ci:9090

### Key Metrics to Monitor

1. **Application Performance**

   - Response times
   - Error rates
   - Throughput
   - User sessions

2. **Infrastructure**

   - CPU and memory usage
   - Disk space
   - Network I/O
   - Database performance

3. **Business Metrics**
   - Order completion rates
   - Payment success rates
   - User registrations
   - Courier utilization

## Troubleshooting

### Common Issues

#### 1. Build Failures

```bash
# Clean and rebuild
flutter clean
flutter pub get
flutter build web --release
```

#### 2. Container Issues

```bash
# Check container logs
docker logs le-livreur-pro

# Restart container
docker restart le-livreur-pro

# Rebuild image
docker build --no-cache -t lelivreurpro/app:latest .
```

#### 3. Database Connection Issues

- Verify Supabase configuration
- Check network connectivity
- Validate credentials
- Review RLS policies

#### 4. Payment Integration Issues

- Verify API credentials
- Check payment gateway status
- Review webhook configurations
- Monitor transaction logs

### Debugging Commands

```bash
# Check application status
kubectl get pods -n le-livreur-pro

# View detailed pod information
kubectl describe pod <pod-name> -n le-livreur-pro

# Access pod shell
kubectl exec -it <pod-name> -n le-livreur-pro -- /bin/sh

# View application logs
kubectl logs -f deployment/le-livreur-app -n le-livreur-pro

# Check ingress configuration
kubectl describe ingress le-livreur-ingress -n le-livreur-pro
```

## Backup and Recovery

### Database Backups

```bash
# Automated daily backups via Supabase
# Manual backup
supabase db dump --file backup-$(date +%Y%m%d).sql

# Restore from backup
supabase db reset --file backup-20240101.sql
```

### Application State Backup

- User uploaded files
- Configuration files
- SSL certificates
- Application logs

### Disaster Recovery Plan

1. Database restoration from latest backup
2. Application redeployment from Git
3. DNS failover configuration
4. External service reconfiguration

## Scaling

### Horizontal Scaling

```bash
# Scale deployment
kubectl scale deployment le-livreur-app --replicas=5 -n le-livreur-pro

# Configure auto-scaling
kubectl apply -f deployment/k8s/production/hpa.yaml
```

### Vertical Scaling

```bash
# Update resource limits
kubectl patch deployment le-livreur-app -n le-livreur-pro -p '{"spec":{"template":{"spec":{"containers":[{"name":"le-livreur-app","resources":{"requests":{"cpu":"200m","memory":"256Mi"},"limits":{"cpu":"1000m","memory":"1Gi"}}}]}}}}'
```

## Security

### SSL/TLS Configuration

- Automatic certificate management with Let's Encrypt
- HSTS headers enabled
- Secure cipher suites
- Regular certificate renewal

### Security Headers

- Content Security Policy (CSP)
- X-Frame-Options
- X-XSS-Protection
- X-Content-Type-Options
- Referrer-Policy

### Network Security

- Network policies in Kubernetes
- Rate limiting
- DDoS protection
- WAF (Web Application Firewall)

## Performance Optimization

### Web Performance

- Gzip compression enabled
- Static asset caching
- CDN for static files
- Image optimization
- Code splitting

### Database Performance

- Connection pooling
- Query optimization
- Index management
- Regular maintenance

### Caching Strategy

- Redis for session storage
- Browser caching for static assets
- API response caching
- Database query caching

## Support and Maintenance

### Update Process

1. Test updates in development
2. Deploy to staging for QA
3. Schedule production deployment
4. Monitor post-deployment metrics
5. Rollback if issues detected

### Regular Maintenance

- Security updates
- Dependency updates
- Performance monitoring
- Backup verification
- Log rotation
- Certificate renewal

### Contact Information

- **Technical Support**: tech@lelivreurpro.ci
- **Infrastructure**: ops@lelivreurpro.ci
- **Emergency**: +225-xxx-xxxx

## Appendix

### Useful Commands

```bash
# View all resources
kubectl get all -n le-livreur-pro

# Check resource usage
kubectl top pods -n le-livreur-pro

# View events
kubectl get events -n le-livreur-pro --sort-by='.lastTimestamp'

# Port forward for debugging
kubectl port-forward svc/le-livreur-service 8080:80 -n le-livreur-pro
```

### External Documentation

- [Flutter Deployment Guide](https://docs.flutter.dev/deployment)
- [Supabase Documentation](https://supabase.com/docs)
- [Kubernetes Documentation](https://kubernetes.io/docs/)
- [Docker Documentation](https://docs.docker.com/)
- [Nginx Documentation](https://nginx.org/en/docs/)

---

**Note**: This deployment guide is specific to the Le Livreur Pro application for the Côte d'Ivoire market. Adjust configurations based on your specific requirements and infrastructure setup.
