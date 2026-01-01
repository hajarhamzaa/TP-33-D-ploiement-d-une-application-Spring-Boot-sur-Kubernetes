# TP 33 : Déploiement d'une application Spring Boot sur Kubernetes

## Objectifs 
À la fin de ce lab, l'étudiant est capable de :
- Conteneuriser une application Spring Boot avec Docker
- Créer les manifests Kubernetes de base : Deployment et Service
- Déployer l'application sur un cluster Kubernetes local (Minikube)
- Exposer l'API Spring Boot vers l'extérieur du cluster
- Vérifier le fonctionnement et observer les pods
- **Utiliser les ConfigMap pour externaliser la configuration**
- **Observer et diagnostiquer les déploiements Kubernetes**

## Pré-requis techniques
- Java 17 ou 21 installé
- Maven installé
- Docker installé et en fonctionnement
- Minikube ou autre cluster Kubernetes local (kind, k3d, etc.)
- kubectl configuré pour accéder au cluster

## Structure du projet
```
demo-k8s/
├── pom.xml
├── Dockerfile
├── k8s-deployment.yaml
├── k8s-service.yaml
├── k8s-configmap.yaml          # NOUVEAU : ConfigMap pour la configuration
├── README.md
├── EXTENSIONS.md               # NOUVEAU : Pistes d'extension
├── deploy.sh / deploy.bat      # Scripts de déploiement simple
├── deploy-complete.sh          # NOUVEAU : Déploiement avec ConfigMap
├── observe.sh / observe.bat    # NOUVEAU : Scripts d'observation
├── cleanup.sh                  # Nettoyage simple
└── cleanup-complete.sh         # NOUVEAU : Nettoyage complet
└── src/
    └── main/
        ├── java/com/example/demok8s/
        │   ├── DemoK8sApplication.java
        │   └── api/
        │       └── HelloController.java    # MODIFIÉ : Utilise @Value pour lire les variables
        └── resources/
            └── application.properties
```

## Étapes du TP

### 📦 Étape 1-7 : Déploiement de base
*(Voir section "Déploiement rapide" ci-dessous)*

### 🔍 Étape 8 : Observation et diagnostic
```bash
# Scripts d'observation automatique
./observe.sh        # Linux/Mac
observe.bat         # Windows

# Ou manuellement :
kubectl get pods -n lab-k8s
kubectl get svc -n lab-k8s
kubectl logs <pod-name> -n lab-k8s
kubectl describe deployment demo-k8s-deployment -n lab-k8s
```

### ⚙️ Étape 9 : Variante avec ConfigMap
```bash
# Déploiement avec ConfigMap (recommandé)
./deploy-complete.sh

# Ou manuellement :
kubectl apply -f k8s-configmap.yaml
kubectl apply -f k8s-deployment.yaml
kubectl apply -f k8s-service.yaml
```

**Résultat attendu avec ConfigMap** :
```json
{
  "message": "Hello from ConfigMap in Kubernetes",
  "status": "OK"
}
```

### 🧹 Étape 10 : Nettoyage
```bash
# Nettoyage complet
./cleanup-complete.sh      # Linux/Mac
cleanup-complete.bat       # Windows

# Ou manuellement :
kubectl delete -f k8s-service.yaml
kubectl delete -f k8s-deployment.yaml
kubectl delete -f k8s-configmap.yaml
kubectl delete namespace lab-k8s
minikube stop
```

## 🚀 Déploiement rapide

### Option 1 : Déploiement simple
```bash
./deploy.sh        # Linux/Mac
deploy.bat         # Windows
```

### Option 2 : Déploiement complet avec ConfigMap (recommandé)
```bash
./deploy-complete.sh    # Linux/Mac
```

### Option 3 : Déploiement manuel
```bash
# 1. Construction
mvn clean package -DskipTests

# 2. Minikube
minikube start
eval $(minikube docker-env)  # Linux/Mac seulement

# 3. Image Docker
docker build -t demo-k8s:1.0.0 .

# 4. Namespace
kubectl create namespace lab-k8s

# 5. ConfigMap (optionnel mais recommandé)
kubectl apply -f k8s-configmap.yaml

# 6. Application
kubectl apply -f k8s-deployment.yaml
kubectl apply -f k8s-service.yaml

# 7. Test
MINIKUBE_IP=$(minikube ip)
curl http://$MINIKUBE_IP:30080/api/hello
```

## 🎯 Points clés du TP

### Concepts appris
- **Conteneurisation** : Dockerfile, build d'image
- **Kubernetes** : Pods, Deployments, Services, ConfigMaps
- **Configuration** : Variables d'environnement, externalisation
- **Monitoring** : Logs, description des ressources, événements
- **Exposition** : NodePort, accès intra-cluster

### Bonnes pratiques implémentées
- ✅ Probes de santé (readiness/liveness)
- ✅ Configuration externalisée avec ConfigMap
- ✅ Scripts automatisés pour toutes les opérations
- ✅ Namespace dédié pour l'isolation
- ✅ Documentation complète


