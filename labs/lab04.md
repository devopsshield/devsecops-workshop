# 4 - Adding Additional DevSecOps Controls
In this lab you will reuse workflow templates.
> Duration: 10-15 minutes

References:
- [Reusing workflows](https://docs.github.com/en/actions/using-workflows/reusing-workflows)
- [Sharing workflows with your organization](https://docs.github.com/en/actions/using-workflows/sharing-workflows-secrets-and-runners-with-your-organization)
- [Sharing actions and workflows with your enterprise](https://docs.github.com/en/enterprise-cloud@latest/actions/creating-actions/sharing-actions-and-workflows-with-your-enterprise)
- [Using starter workflows](https://docs.github.com/en/actions/using-workflows/advanced-workflow-features#using-starter-workflows)

## 4.1 Secret Scanning with Gitleaks

1. For Gitleaks Secret Scanning, uncomment this action:
![image](https://github.com/devopsshield/devsecops-workshop/assets/112144174/0894fb96-77a9-4d16-96ac-b17a20d325f6)

## 4.2 Software Composition Analysis with OWASP Dependency Check

1. Uncomment the actions ```dependency-check/Dependency-Check_Action@main```
![image](https://github.com/devopsshield/devsecops-workshop/assets/112144174/69843416-215b-440f-ba3a-b5c83f393ae5)
1. See the pipeline run


## 4.3 Static Application Security Test with CodeQL

1. Enable

