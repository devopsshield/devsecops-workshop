# 3 - Running the Basic and Advanced DevSecOps Pipelines
In this lab you will use environments and secrets.
> Duration: 10-15 minutes

References:
- [Using environments for deployment](https://docs.github.com/en/actions/deployment/targeting-different-environments/using-environments-for-deployment)
- [Encrypted secrets](https://docs.github.com/en/actions/security-guides/encrypted-secrets)
- [Accessing your secrets](https://docs.github.com/en/actions/security-guides/encrypted-secrets#accessing-your-secrets)

## 3.1 Create new environments, variables, and secrets - basic pipeline

1. In order to run the basic pipeline, you must first enable workflows.
![image](https://github.com/devopsshield/oss-pygoat-devsecops/assets/112144174/cd0f7635-4157-447a-bf7a-a6865e7a918e)
2. Create an environment called `dev`
![image](https://github.com/devopsshield/oss-pygoat-devsecops/assets/112144174/212b5619-5a9f-4ccd-adcb-23627ff50228)
4. Then add 2 environment secrets called `TOKEN_FOR_DOS` and `DEFECTDOJO_COMMONPASSWORD`
![image](https://github.com/devopsshield/oss-pygoat-devsecops/assets/112144174/7d126c06-17eb-42f8-9d53-25827900c81e)
6. TOKEN_FOR_DOS should be a GitHub Personal Access Token (classic) with Read Only permissions:
![image](https://github.com/devopsshield/oss-pygoat-devsecops/assets/112144174/a20204fb-1792-4871-8f91-8ba950e71fc4)
![image](https://github.com/devopsshield/oss-pygoat-devsecops/assets/112144174/afcc91f3-b139-49aa-9afe-7e30b5b65385)
![image](https://github.com/devopsshield/oss-pygoat-devsecops/assets/112144174/aa20d773-7dc8-4382-82bc-39f7994f0a72)
6. If needed, you can always edit personal access token permissions
![image](https://github.com/devopsshield/oss-pygoat-devsecops/assets/112144174/f782d2c8-e1ff-4ca3-a933-f0174073615e)
![image](https://github.com/devopsshield/oss-pygoat-devsecops/assets/112144174/55c6cf39-2880-42bf-9a15-1cc85b9a6be0)
6. The other secret DEFECTDOJO_COMMONPASSWORD can be found here:
![image](https://github.com/devopsshield/oss-pygoat-devsecops/assets/112144174/88fe0bce-1933-4021-b15a-09cf3329f3f8)
7. Once both secrets are entered
![image](https://github.com/devopsshield/oss-pygoat-devsecops/assets/112144174/07342ca1-832d-434c-8581-17e52cec7341)
9. Go ahead and run the basic pipeline!
![image](https://github.com/devopsshield/oss-pygoat-devsecops/assets/112144174/df5be1dc-45d5-459d-992e-46ef6d13f05e)
10. When all is done:
![image](https://github.com/devopsshield/oss-pygoat-devsecops/assets/112144174/efa09478-6536-433b-ab72-2c2ed7293b8d)
![image](https://github.com/devopsshield/oss-pygoat-devsecops/assets/112144174/a1c0f519-924c-4362-af13-a81ee3e04b2d)
11. Modify the GitHub PAT to see the errors detected by DevOps Shield Scanner. Additionally, see the compliance get better as you add more GitHub actions that improve your DevSecOps.
![image](https://github.com/devopsshield/oss-pygoat-devsecops/assets/112144174/28beb9b0-3b2a-4298-9b70-ee450273e233)


## 3.2 Create new environments, variables, and secrets - advanced pipeline

1. Try running the advanced pipeline and you will quickly see it fail
![image](https://github.com/devopsshield/devsecops-workshop/assets/112144174/f415605a-e5b8-44bd-800b-abca9a0eb68a)
3. You can immediately remedy this by running
```POWERSHELL
.\Create-GitHubEnvironments.ps1 -ghOwner emmanuel-knafo `
    -ghRepo devsecops-workshop `
    -dockerName crs001fwmpo7kn3hnty `
    -dockerPassword "Dgv*************************************************" `
    -defectDojoProductId 6 `
    -defectDojoToken "607*************************************" `
    -githubReadOnlyPersonalAccessTokenClassic "ghp_pPK*********************************" `
    -kubeConfigFileName "C:\Users\emmanuel.DEVOPSABCS\Downloads\wrkshp-001-student-001-config-aks-wrkshp-001-s-001"
```
3. You can grab all the parameter values from the OneDrive file you received:
![image](https://github.com/devopsshield/devsecops-workshop/assets/112144174/e8e19ef5-f2c0-475c-8980-c80c56bbf176)
4. Or you can enter each environment secret and variable manually till you get something like:
![image](https://github.com/devopsshield/devsecops-workshop/assets/112144174/064215a3-a8d8-4650-950e-d2c1cd93032e)
![image](https://github.com/devopsshield/devsecops-workshop/assets/112144174/b8a1ecdc-f215-4d12-bc25-500113c05f87)
![image](https://github.com/devopsshield/devsecops-workshop/assets/112144174/e866fe16-7770-4f57-9942-c500121ceb10)
6. Then run the advanced pipeline again
![image](https://github.com/devopsshield/devsecops-workshop/assets/112144174/87935f10-003c-4a46-a76c-3973b17e35fa)
7. It should end like this:
![image](https://github.com/devopsshield/devsecops-workshop/assets/112144174/50900633-57f7-43c5-ae5c-7b20fa5a4ae0)
9. You can view the deployed app here: http://gh-pygoat.cad4devops.com or find the ip in the deployment such as http://20.175.206.146 :
![image](https://github.com/devopsshield/devsecops-workshop/assets/112144174/ba4b6912-f616-4da9-b2ff-2eb1ab118afa)
10. The [Live Demo of the Pygoat app](http://gh-pygoat.cad4devops.com) is a great way to learn more about DevSecOps. Please bear in mind that this app is **intentionally insecure**!
![image](https://github.com/devopsshield/devsecops-workshop/assets/112144174/aea2bf6e-538e-465e-821b-6518b047ce92)
