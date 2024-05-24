# 1 - Introduction to Defect Dojo
In this lab you will learn about Defect Dojo.
For the purposes of this lab, we will assume we are **Student003** of **Workshop 001**.
> Duration: 5-10 minutes

References:
- [Events that trigger workflows](https://docs.github.com/en/actions/using-workflows/events-that-trigger-workflows)
- [Adding an action to your workflow](https://docs.github.com/en/actions/learn-github-actions/finding-and-customizing-actions#adding-an-action-to-your-workflow)

## 1.1 Log in

1. You should have received en email with access to a OneDrive folder for your workshop. Open that folder:
![image](https://github.com/devopsshield/oss-pygoat-devsecops/assets/112144174/1c3ae5a9-ce28-4bad-aadc-3333e427a1ed)
2. Open the subfolder corresponding to your student number. In our case, it's 003:
![image](https://github.com/devopsshield/oss-pygoat-devsecops/assets/112144174/60b97325-c429-4c8c-8c4a-e75063e752ac)
3. Observe the contents of the student info text file. We have:
```
Workshop Number: 001
Student Number: 003
Defect Dojo Url: https://defectdojo-002.cad4devops.com:8443/
Defect Dojo User Name: Student003
Defect Dojo Password: P@ssw0rd!1
Defect Dojo Product Name: GitHub-OSS-pygoat-devsecops-workshop-001-product-003
Azure Container Registry Name: crs003r46vs7qui3ejw
Azure Container Registry Password: TUf************************************************
```
4. Now navigate to your [Defect Dojo Instance](https://defectdojo-002.cad4devops.com:8443/) and log in:
![image](https://github.com/devopsshield/oss-pygoat-devsecops/assets/112144174/fcc342ee-e1d1-4a4a-8d92-145d36ffe111)
6. Navigate to your product and make note of your **product id**
![image](https://github.com/devopsshield/oss-pygoat-devsecops/assets/112144174/efab9afd-ac31-4994-ae4b-e0bf32a55122)
![image](https://github.com/devopsshield/oss-pygoat-devsecops/assets/112144174/3d2afeec-650b-45fc-8b23-348cb2080bd7)
8. In our case, our product id is **12**
![image](https://github.com/devopsshield/oss-pygoat-devsecops/assets/112144174/d39e1a91-169e-451d-bad3-56e2069ccbd9)


## 1.2 Add steps to your workflow

1. Open the workflow file [github-actions-demo.yml](/.github/workflows/github-actions-demo.yml)
2. Edit the file and copy the following YAML content at the end of the file:
```YAML
        # This step uses GitHub's hello-world-javascript-action: https://github.com/actions/hello-world-javascript-action
      - name: Hello world
        uses: actions/hello-world-javascript-action@main
        with:
          who-to-greet: "Mona the Octocat"
        id: hello
      # This step prints an output (time) from the previous step's action.
      - name: Echo the greeting's time
        run: echo 'The time was ${{ steps.hello.outputs.time }}.'   
```
3. Optional remove the `paths` to trigger the workflow on any push to main branch
4. Commit the changes into the `main` branch
5. If not step 3), change a file inside the folder [labs](/labs) and commit the changes into the `main` branch
6. Go to `Actions` and see the details of your running workflow

## 1.3 Final
<details>
  <summary>github-actions-demo.yml</summary>
  
```YAML
name: 01-1. GitHub Actions Demo
on: 
  workflow_dispatch:
  workflow_call:
  push:
    branches:
      - main

jobs:
  Explore-GitHub-Actions:
    runs-on: ubuntu-latest
    steps:
      - run: echo "🎉 The job was automatically triggered by a ${{ github.event_name }} event."
      - run: echo "🐧 This job is now running on a ${{ runner.os }} server hosted by GitHub!"
      - run: echo "🔎 The name of your branch is ${{ github.ref }} and your repository is ${{ github.repository }}."
      - name: Check out repository code
        uses: actions/checkout@v4
      - run: echo "💡 The ${{ github.repository }} repository has been cloned to the runner."
      - run: echo "🖥️ The workflow is now ready to test your code on the runner."
      - name: List files in the repository
        run: |
          ls ${{ github.workspace }}
      - run: echo "🍏 This job's status is ${{ job.status }}."
      - name: Adding markdown
        run: echo "### Hello world! :rocket:" >> "$GITHUB_STEP_SUMMARY"
      # This step uses GitHub's hello-world-javascript-action: https://github.com/actions/hello-world-javascript-action
      - name: Hello world
        uses: actions/hello-world-javascript-action@main
        with:
          who-to-greet: "Mona the Octocat"
        id: hello
      # This step prints an output (time) from the previous step's action.
      - name: Echo the greeting's time
        run: echo 'The time was ${{ steps.hello.outputs.time }}.'   
```
</details>

