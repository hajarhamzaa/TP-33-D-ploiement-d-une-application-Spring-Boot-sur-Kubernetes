#!/bin/bash

# Étape 10 - Nettoyage complet du lab

echo "🧹 Étape 10 - Nettoyage complet du lab"
echo "==================================="

echo "🗑️ 1. Suppression des ressources Kubernetes"
echo "----------------------------------------"
echo "Suppression du service..."
kubectl delete -f k8s-service.yaml --ignore-not-found=true

echo "Suppression du deployment..."
kubectl delete -f k8s-deployment.yaml --ignore-not-found=true

echo "Suppression de la ConfigMap..."
kubectl delete -f k8s-configmap.yaml --ignore-not-found=true

echo "Suppression du namespace lab-k8s..."
kubectl delete namespace lab-k8s --ignore-not-found=true

echo -e "\n🔥 2. Arrêt de Minikube"
echo "----------------------"
minikube stop

echo -e "\n🗑️ 3. Suppression des images locales (optionnel)"
echo "------------------------------------------------"
read -p "Voulez-vous supprimer l'image Docker demo-k8s:1.0.0 ? (y/N): " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    docker rmi demo-k8s:1.0.0 --ignore-not-found=true
    echo "Image Docker supprimée"
fi

echo -e "\n🧼 4. Nettoyage des fichiers temporaires locaux"
echo "----------------------------------------------"
if [ -d "target" ]; then
    echo "Suppression du répertoire target..."
    rm -rf target
fi

echo -e "\n✅ Nettoyage terminé avec succès!"
echo "=================================="
echo "Toutes les ressources Kubernetes ont été supprimées"
echo "Minikube est arrêté"
echo "Le système est maintenant propre"
