#!/bin/bash

# Étape 8 - Observation et diagnostic

echo "🔍 Étape 8 - Observation et diagnostic"
echo "=================================="

echo "📋 1. Liste des pods et services"
echo "--------------------------------"
echo "Pods dans le namespace lab-k8s :"
kubectl get pods -n lab-k8s

echo -e "\nServices dans le namespace lab-k8s :"
kubectl get svc -n lab-k8s

echo -e "\n📝 2. Logs d'un pod"
echo "----------------------"
# Récupérer le nom du premier pod disponible
POD_NAME=$(kubectl get pods -n lab-k8s -o jsonpath='{.items[0].metadata.name}')
if [ ! -z "$POD_NAME" ]; then
    echo "Logs du pod $POD_NAME :"
    kubectl logs $POD_NAME -n lab-k8s
else
    echo "Aucun pod trouvé dans le namespace lab-k8s"
fi

echo -e "\n🌐 3. Accès inside cluster (optionnel)"
echo "------------------------------------"
echo "Pour tester l'accès depuis l'intérieur du cluster :"
echo "kubectl run curl-pod -n lab-k8s --image=alpine/curl -it -- sh"
echo "Puis dans le pod: curl http://demo-k8s-service:8080/api/hello"

echo -e "\n📊 4. Description détaillée des ressources"
echo "----------------------------------------"
echo "Description du deployment :"
kubectl describe deployment demo-k8s-deployment -n lab-k8s

echo -e "\nDescription du service :"
kubectl describe service demo-k8s-service -n lab-k8s

echo -e "\n🔧 5. Vérification des événements"
echo "------------------------------"
echo "Événements récents dans le namespace lab-k8s :"
kubectl get events -n lab-k8s --sort-by='.lastTimestamp' | tail -10
