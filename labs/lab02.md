# 2 - Explore Your Kubernetes Cluster
In this lab you will explore your kubernetes cluster using kubectl.
> Duration: 5-10 minutes

References:
- [Learn Kubernetes Basics](https://kubernetes.io/docs/tutorials/kubernetes-basics/)

## 2.1 If you intend to run the advanced DevSecOps pipeline...

1. Download the kubeconfig file from OneDrive
![image](https://github.com/devopsshield/oss-pygoat-devsecops/assets/112144174/72354cb0-461e-4077-a951-a2e207782148)
3. Explore the contents of this YAML file:
![image](https://github.com/devopsshield/oss-pygoat-devsecops/assets/112144174/fa49b1c5-60b8-4e4a-ac75-6f4f8374d07b)
3. Use kubectl to verify access to the kubernetes cluster
```
kubectl --kubeconfig="C:\Users\emknafo\Downloads\wrkshp-001-student-003-config-aks-wrkshp-001-s-003" get nodes
```
5. You should get something like this:
![image](https://github.com/devopsshield/oss-pygoat-devsecops/assets/112144174/cbf177b9-1ca4-48ee-b1c7-8d8c8827334f)
7. Congratulations! You have access to your workshop kubernetes cluster!
