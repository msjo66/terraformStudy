echo "$(terraform output kube_config)" > ./azurek8s
cat ./azurek8s #### <<EOT 없애야 함
export KUBECONFIG=./azurek8s
kubectl get nodes
kubectl apply -f aks-store-quickstart.yaml
kubectl get service store-front --watch

## clear
terraform plan -destroy -out main.destroy.tfplan