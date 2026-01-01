# Pistes d'extension du TP 33

## 🚀 Idées pour aller plus loin

### 1. Ajout de Spring Boot Actuator
**Objectif** : Améliorer le monitoring et la santé de l'application

**Étapes** :
1. Ajouter la dépendance dans `pom.xml` :
```xml
<dependency>
    <groupId>org.springframework.boot</groupId>
    <artifactId>spring-boot-starter-actuator</artifactId>
</dependency>
```

2. Configurer les probes dans `k8s-deployment.yaml` :
```yaml
readinessProbe:
  httpGet:
    path: /actuator/health/readiness
    port: 8080
  initialDelaySeconds: 10
  periodSeconds: 5
livenessProbe:
  httpGet:
    path: /actuator/health/liveness
    port: 8080
  initialDelaySeconds: 20
  periodSeconds: 10
```

3. Ajouter la configuration dans `application.properties` :
```properties
management.endpoints.web.exposure.include=health,info,metrics
management.endpoint.health.show-details=always
```

### 2. Création d'un Ingress
**Objectif** : Exposer l'application avec un nom de domaine local

**Fichier `k8s-ingress.yaml`** :
```yaml
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: demo-k8s-ingress
  namespace: lab-k8s
  annotations:
    nginx.ingress.kubernetes.io/rewrite-target: /
spec:
  rules:
  - host: demo-k8s.local
    http:
      paths:
      - path: /
        pathType: Prefix
        backend:
          service:
            name: demo-k8s-service
            port:
              number: 8080
```

**Configuration locale** :
```bash
# Ajouter dans /etc/hosts
echo "127.0.0.1 demo-k8s.local" | sudo tee -a /etc/hosts

# Installer NGINX Ingress Controller
minikube addons enable ingress
```

### 3. Pipeline CI/CD avec GitHub Actions
**Fichier `.github/workflows/deploy.yml`** :
```yaml
name: Deploy to Kubernetes

on:
  push:
    branches: [ main ]

jobs:
  build-and-deploy:
    runs-on: ubuntu-latest
    steps:
    - uses: actions/checkout@v3
    
    - name: Set up JDK 17
      uses: actions/setup-java@v3
      with:
        java-version: '17'
        distribution: 'temurin'
    
    - name: Build with Maven
      run: mvn clean package -DskipTests
    
    - name: Build Docker image
      run: |
        docker build -t demo-k8s:${{ github.sha }} .
        docker tag demo-k8s:${{ github.sha }} demo-k8s:latest
    
    - name: Deploy to Kubernetes
      run: |
        kubectl apply -f k8s-configmap.yaml
        kubectl apply -f k8s-deployment.yaml
        kubectl apply -f k8s-service.yaml
```

### 4. Ajout d'un deuxième microservice
**Objectif** : Tester la communication entre services

**Nouveau service : User Service**
- Créer un nouveau projet Spring Boot `user-service`
- Endpoint `/api/users` qui retourne une liste d'utilisateurs
- Configurer la communication entre `demo-k8s` et `user-service`

**Communication intra-cluster** :
```java
@Value("${USER_SERVICE_URL:http://user-service:8081}")
private String userServiceUrl;

@GetMapping("/api/users")
public ResponseEntity<List<User>> getUsers() {
    // Appel au user-service via le nom du service Kubernetes
    return restTemplate.getForEntity(userServiceUrl + "/api/users", 
                                   new ParameterizedTypeReference<List<User>>() {});
}
```

### 5. Configuration avancée avec Secrets
**Fichier `k8s-secret.yaml`** :
```yaml
apiVersion: v1
kind: Secret
metadata:
  name: demo-k8s-secret
  namespace: lab-k8s
type: Opaque
data:
  db-password: c3VwZXItc2VjcmV0LXBhc3N3b3Jk  # base64 encoded
  api-key: YXBpLWtleS12YWx1ZQ==
```

**Utilisation dans le Deployment** :
```yaml
env:
  - name: DB_PASSWORD
    valueFrom:
      secretKeyRef:
        name: demo-k8s-secret
        key: db-password
```

### 6. Monitoring avec Prometheus et Grafana
**Installation** :
```bash
# Ajouter les repos Helm
helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
helm repo update

# Installer Prometheus
helm install prometheus prometheus-community/kube-prometheus-stack
```

**Configuration des métriques** :
```properties
# application.properties
management.metrics.export.prometheus.enabled=true
management.endpoint.metrics.enabled=true
```

### 7. Autoscaling avec HPA
**Fichier `k8s-hpa.yaml`** :
```yaml
apiVersion: autoscaling/v2
kind: HorizontalPodAutoscaler
metadata:
  name: demo-k8s-hpa
  namespace: lab-k8s
spec:
  scaleTargetRef:
    apiVersion: apps/v1
    kind: Deployment
    name: demo-k8s-deployment
  minReplicas: 2
  maxReplicas: 10
  metrics:
  - type: Resource
    resource:
      name: cpu
      target:
        type: Utilization
        averageUtilization: 70
```

### 8. Tests automatisés
**Tests de charge avec K6** :
```javascript
// load-test.js
import http from 'k6/http';
import { check } from 'k6';

export default function () {
  let response = http.get('http://demo-k8s-service:8080/api/hello');
  check(response, {
    'status is 200': (r) => r.status === 200,
    'response time < 500ms': (r) => r.timings.duration < 500,
  });
}
```

### 9. Sécurité avancée
**Network Policies** :
```yaml
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: demo-k8s-netpol
  namespace: lab-k8s
spec:
  podSelector:
    matchLabels:
      app: demo-k8s
  policyTypes:
  - Ingress
  - Egress
  ingress:
  - from:
    - namespaceSelector:
        matchLabels:
          name: lab-k8s
    ports:
    - protocol: TCP
      port: 8080
```

### 10. Backup et restauration
**Script de backup** :
```bash
#!/bin/bash
# backup-k8s.sh
kubectl get configmap demo-k8s-config -n lab-k8s -o yaml > backup-configmap.yaml
kubectl get deployment demo-k8s-deployment -n lab-k8s -o yaml > backup-deployment.yaml
kubectl get service demo-k8s-service -n lab-k8s -o yaml > backup-service.yaml
```

## 📚 Ressources complémentaires

- **Documentation Kubernetes** : https://kubernetes.io/docs/
- **Spring Boot Kubernetes** : https://spring.io/guides/gs/spring-boot-kubernetes/
- **Best Practices** : https://kubernetes.io/docs/concepts/configuration/overview/
- **Patterns Kubernetes** : https://kubernetes.io/docs/concepts/cluster-administration/managed-field-selectors/

## 🎯 Prochaines étapes suggérées

1. **Maîtriser les bases** : Assurez-vous de bien comprendre les concepts fondamentaux
2. **Expérimenter** : Testez chaque extension dans un environnement de développement
3. **Monitoring** : Mettez en place des alertes et des dashboards
4. **Sécurité** : Implémentez les meilleures pratiques de sécurité
5. **Performance** : Optimisez les performances et les coûts
