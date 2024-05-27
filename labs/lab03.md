# 3 - Environments and Secrets
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
4. Then add 2 environment secrets called `TOKEN_FOR_DOS` and `DEFECTDOJO_COMMON_PASSWORD`
![image](https://github.com/devopsshield/oss-pygoat-devsecops/assets/112144174/7d126c06-17eb-42f8-9d53-25827900c81e)
6. TOKEN_FOR_DOS should be a GitHub Personal Access Token (classic) with Read Only permissions:

6. Update the workflow to also run on push and pull_request events
```YAML
on:
  push:
     branches: [main]
  pull_request:
     branches: [main]
  workflow_dispatch:    
```
7. Commit the changes into the `main` branch
8. Go to `Actions` and see the details of your running workflow


## 3.2 Create new environments, variables, and secrets - advanced pipeline

1. Open the workflow file [environments-secrets.yml](/.github/workflows/environments-secrets.yml)
2. Edit the file and copy the following YAML content between the test and prod jobs (before the `use-environment-prod:` line):
```YAML

  use-environment-uat:
    name: Use UAT environment
    runs-on: ubuntu-latest
    if: ${{ github.event_name == 'push' && github.ref == 'refs/heads/main' }}
    needs: use-environment-test

    environment:
      name: UAT
      url: 'https://uat.github.com'
    
    steps:
      - name: Step that uses the UAT environment
        run: echo "Deployment to UAT..."
        env: 
          env_secret: ${{ secrets.MY_ENV_SECRET }}

```
7. Inside the `use-environment-prod` job, replace `needs: use-environment-test` with:
```YAML
    needs: use-environment-uat
```
8. Commit the changes into the `main` branch
9. Go to `Actions` and see the details of your running workflow
10. Review your deployment and approve the pending UAT job
    - [Reviewing deployments](https://docs.github.com/en/actions/managing-workflow-runs/reviewing-deployments)
11. Go to `Settings` > `Environments` and update the `PROD` environment created to protect it with approvals (same as UAT)
