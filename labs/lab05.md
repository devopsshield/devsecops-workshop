# 5 - Holistic Compliance View with DevOps Shield UI
In this lab you will create and use custom actions.
> Duration: 15-20 minutes

References:
- [Creating actions](https://docs.github.com/en/actions/creating-actions)
- [Creating a composite action](https://docs.github.com/en/actions/creating-actions/creating-a-composite-action)
- [Creating a JavaScript action](https://docs.github.com/en/actions/creating-actions/creating-a-javascript-action)
- [GitHub Actions Toolkit](https://github.com/actions/toolkit)
- [actions/github-script](https://github.com/actions/github-script)

## 5.1 Run the Docker Container of DevOps Shield

1. As per [DevOps Shield on DockerHub](https://hub.docker.com/r/devopsshield/devopsshield)
```
docker run -d -p 8080:8080 devopsshield/devopsshield
```
![image](https://github.com/devopsshield/devsecops-workshop/assets/112144174/7ca6e4bf-da09-42b2-b4db-b492cdd01f25)
2. Log into http://localhost:8080 with username **devopsshield** and password **devopsshield**
![image](https://github.com/devopsshield/devsecops-workshop/assets/112144174/24c1b52e-4a12-4c9a-89c0-155bc5f00358)
![image](https://github.com/devopsshield/devsecops-workshop/assets/112144174/46389907-1f3e-49b8-b6e5-0b81a9886001)
3. Once logged in, click Setup Configuration
![image](https://github.com/devopsshield/devsecops-workshop/assets/112144174/ec0a50d3-6773-4cd1-ad1f-8b0ef665083b)
4. Now click on Quick Setup - Get Started
![image](https://github.com/devopsshield/devsecops-workshop/assets/112144174/c39c4cb5-f86a-4f63-8dd0-9eed2a397818)
5. You can reuse the same GitHub PAT you used previously
![image](https://github.com/devopsshield/devsecops-workshop/assets/112144174/5c092ae7-13eb-444d-b7a7-6f565847a43f)
6. Now click on start setup now
![image](https://github.com/devopsshield/devsecops-workshop/assets/112144174/3ea36eb2-95ca-4884-8700-723fe1c7f6c4)
7. Explore the results once the scan is done
