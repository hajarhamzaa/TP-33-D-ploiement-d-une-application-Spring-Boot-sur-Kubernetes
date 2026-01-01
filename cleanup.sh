# Script de nettoyage du TP 33

echo 🧹 Nettoyage du déploiement Kubernetes

# Suppression du namespace et de toutes ses ressources
kubectl delete namespace lab-k8s --ignore-not-found=true

# Arrêt de Minikube
minikube stop

# Optionnel: Suppression des images locales
docker rmi demo-k8s:1.0.0 --ignore-not-found=true

echo ✅ Nettoyage terminé
