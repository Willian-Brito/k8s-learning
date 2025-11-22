#!/bin/bash
kubectl run pod-lifecycle-running --image=desenvolvedorio/dominando-kubernetes:pod-lifecycle-running
kubectl run pod-lifecycle-failed --image=desenvolvedorio/dominando-kubernetes:pod-lifecycle-failed --dry-run=client -o yaml > pod-lifecycle-failed.yaml
kubectl create -f pod-lifecycle-failed.yaml
kubectl run pod-lifecycle-succeeded --image=desenvolvedorio/dominando-kubernetes:pod-lifecycle-succeeded --dry-run=client -o yaml > pod-lifecycle-succeeded.yaml
kubectl create -f pod-lifecycle-succeeded.yaml

kubectl create -f pod-lifecycle-succeeded.yaml
kubectl create -f pod-lifecycle-failed.yaml