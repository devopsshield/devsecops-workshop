# 5 - Holistic Compliance View with DevOps Shield UI
In this lab you will run the DevOps Shield Web App locally from a docker container on your laptop.
> Duration: 15-20 minutes

References:
- [DevOps Shield on DockerHub](https://hub.docker.com/r/devopsshield/devopsshield)
- [DevOps Shield Live Demo Website](https://demo.devopsshield.com)

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
![image](https://github.com/devopsshield/devsecops-workshop/assets/112144174/37005629-4287-4e9f-bf45-e891905b5f9f)
![image](https://github.com/devopsshield/devsecops-workshop/assets/112144174/8c6a22ab-a0e9-4030-8091-1fe23678becc)
![image](https://github.com/devopsshield/devsecops-workshop/assets/112144174/bb2f72d3-bf3e-4be8-9fa9-5bd196e4f346)
8. Look at also the DevSecOps Controls
![image](https://github.com/devopsshield/devsecops-workshop/assets/112144174/187f70ef-8c5d-47dc-9bfa-89d4d816fd15)
9. Explore the various Policies and Libraries
![image](https://github.com/devopsshield/devsecops-workshop/assets/112144174/06ae39ce-0903-428e-850f-0e6f83a08d93)
