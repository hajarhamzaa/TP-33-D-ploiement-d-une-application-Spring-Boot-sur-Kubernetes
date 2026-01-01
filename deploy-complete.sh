#!/bin/bash

# Script de déploiement complet avec ConfigMap

echo "🚀 Déploiement complet avec ConfigMap"

# Étape 1: Construction de l'application
echo "📦 Construction de l'application..."
mvn clean package -DskipTests
if [ $? -ne 0 ]; then
    echo "❌ Erreur lors de la construction de l'application"
    exit 1
fi

# Étape 2: Démarrage de Minikube
echo "🔥 Démarrage de Minikube..."
minikube start
if [ $? -ne 0 ]; then
    echo "❌ Erreur lors du démarrage de Minikube"
    exit 1
fi

# Étape 3: Configuration de l'environnement Docker
echo "🐳 Configuration de l'environnement Docker..."
eval $(minikube docker-env)

# Étape 4: Construction de l'image Docker
echo "🏗️ Construction de l'image Docker..."
docker build -t demo-k8s:1.0.0 .
if [ $? -ne 0 ]; then
    echo "❌ Erreur lors de la construction de l'image Docker"
    exit 1
fi

# Étape 5: Création du namespace
echo "📂 Création du namespace..."
kubectl create namespace lab-k8s --dry-run=client -o yaml | kubectl apply -f -

# Étape 6: Déploiement de la ConfigMap
echo "⚙️ Déploiement de la ConfigMap..."
kubectl apply -f k8s-configmap.yaml

# Étape 7: Déploiement de l'application
echo "🚢 Déploiement de l'application..."
kubectl apply -f k8s-deployment.yaml
kubectl apply -f k8s-service.yaml

# Étape 8: Attente du déploiement
echo "⏳ Attente du déploiement..."
kubectl wait --for=condition=available --timeout=300s deployment/demo-k8s-deployment -n lab-k8s

# Étape 9: Vérification
echo "✅ Vérification du déploiement..."
kubectl get pods -n lab-k8s
kubectl get svc -n lab-k8s
kubectl get configmap -n lab-k8s

# Étape 10: Test de l'API
echo "🌐 Test de l'API..."
MINIKUBE_IP=$(minikube ip)
echo "IP de Minikube: $MINIKUBE_IP"
echo "Test de l'endpoint: http://$MINIKUBE_IP:30080/api/hello"

# Attendre un peu que les pods soient prêts
sleep 10
curl http://$MINIKUBE_IP:30080/api/hello

echo "🎉 Déploiement terminé avec succès!"
echo "📝 Pour accéder à l'API: curl http://$MINIKUBE_IP:30080/api/hello"
echo "🔍 Pour observer: ./observe.sh"
echo "🧹 Pour nettoyer: ./cleanup-complete.sh"
