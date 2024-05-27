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
1. Run the pipeline to see
![image](https://github.com/devopsshield/devsecops-workshop/assets/112144174/db223fc0-ce46-422a-a564-04aa9573dc4a)

## 4.2 Software Composition Analysis with OWASP Dependency Check

1. Uncomment the actions ```dependency-check/Dependency-Check_Action@main```
![image](https://github.com/devopsshield/devsecops-workshop/assets/112144174/69843416-215b-440f-ba3a-b5c83f393ae5)
1. See the pipeline run
![image](https://github.com/devopsshield/devsecops-workshop/assets/112144174/5a573256-dd04-4783-b91d-18e3016595da)

## 4.3 Static Application Security Test with CodeQL

1. Enable CodeQL in GitHub security settings
![image](https://github.com/devopsshield/devsecops-workshop/assets/112144174/49a1f30a-7485-4454-bf38-385d19660d32)
3. Be sure to configure the tool
![image](https://github.com/devopsshield/devsecops-workshop/assets/112144174/c2f5d15e-35dc-408c-9a34-bee0a70647e7)
4. Click Enable CodeQL
![image](https://github.com/devopsshield/devsecops-workshop/assets/112144174/d21d21dd-a839-4665-8807-9836172fcc1c)
6. After a scan, you should see some security vulnerabilities
![image](https://github.com/devopsshield/devsecops-workshop/assets/112144174/7bf6aeb6-5f64-4498-ab76-a166bb86c551)
![image](https://github.com/devopsshield/devsecops-workshop/assets/112144174/d74ea483-e82e-4dcc-aae0-6bab275487d7)
