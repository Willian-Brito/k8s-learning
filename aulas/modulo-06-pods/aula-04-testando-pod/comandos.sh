#!/bin/bash
kubectl get po
kubectl port-forward pod/nginx -n default 4200:80
kubectl proxy
kubectl get po -o wide
kubectl run test-network --image=nicolaka/netshoot -i --tty
> curl http://172.17.0.3
kubectl get po