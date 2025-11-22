#!/bin/bash
# adicionar o alias k=kubectl no bashrc
echo "alias k=kubectl" >> ~/.bashrc
kubectl run nginx --image=nginx --dry-run=client -o yaml > pod.yaml
kubectl create -f pod.yaml
kubectl get po
kubectl describe po nginx
kubectl get po nginx -o yaml
kubectl get po nginx -o yaml > pod-criado.yaml