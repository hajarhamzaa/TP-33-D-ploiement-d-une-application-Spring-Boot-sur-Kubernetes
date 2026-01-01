@echo off
REM Étape 10 - Nettoyage complet du lab (Windows)

echo 🧹 Étape 10 - Nettoyage complet du lab
echo ===================================

echo 🗑️ 1. Suppression des ressources Kubernetes
echo ----------------------------------------
echo Suppression du service...
kubectl delete -f k8s-service.yaml --ignore-not-found=true

echo Suppression du deployment...
kubectl delete -f k8s-deployment.yaml --ignore-not-found=true

echo Suppression de la ConfigMap...
kubectl delete -f k8s-configmap.yaml --ignore-not-found=true

echo Suppression du namespace lab-k8s...
kubectl delete namespace lab-k8s --ignore-not-found=true

echo.
echo 🔥 2. Arrêt de Minikube
echo ----------------------
minikube stop

echo.
echo 🗑️ 3. Suppression des images locales (optionnel)
echo ------------------------------------------------
set /p delete_image="Voulez-vous supprimer l'image Docker demo-k8s:1.0.0 ? (y/N): "
if /i "%delete_image%"=="y" (
    docker rmi demo-k8s:1.0.0 --ignore-not-found=true
    echo Image Docker supprimée
)

echo.
echo 🧼 4. Nettoyage des fichiers temporaires locaux
echo ----------------------------------------------
if exist "target" (
    echo Suppression du répertoire target...
    rmdir /s /q target
)

echo.
echo ✅ Nettoyage terminé avec succès!
echo ==================================
echo Toutes les ressources Kubernetes ont été supprimées
echo Minikube est arrêté
echo Le système est maintenant propre
