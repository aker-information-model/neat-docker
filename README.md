# NEAT Config

Docker image tailored for AKSO needs


Follow [instruction](https://docs.github.com/en/enterprise-server@3.4/authentication/keeping-your-account-and-data-secure/creating-a-personal-access-token) and create Github Personal Token. In short we provide quick visual steps on how to generate Github Personal Token here as well.

1. Logging to Github, click at account image and select `Settings`
![](./figs/settings.png)

2. Under setting scroll to the bottom of the page and click on `Developer settings`
![](./figs/developer-settings.png)

3. Click on `Personal access tokens`, then on `Tokens (classic)` and finally on `Generate new token`
![](./figs/personal-token-tokens-generate-token.png)

4. Once menu appears click on `Generate new token (classic)`
![](./figs/generate-classic-token.png)

5. Give this token some memorable note. Ideally you will keep `Expiration` as is, generally speaking do not set it to more than 90 days. Set token to have only `read:packages` scope, we simply want to allow pulling of NEAT docker image not writing!
![](./figs/select-only-read-packages.png)

6. Copy created token and story it somewhere safe (e.g., LastPass)
![](./figs/copy-store-personal-token.png)

6. Click on `Configure SSO` and select `aker-information-model` organization
![](./figs/attach-ptoken-to-akso.png)

7. When presented with new page click `Continue`
![](./figs/continue.png)

8. Once the previous step is completed, when you check `SSO` you should see `deauthorized` next to `aker-information-model`
![](./figs/akso-configured.png)


The above config needs to be done once ever number of days you set for token expiration.
The rest of the process is done via terminal, and expects that you have installed Docker and git on your machine.

In terminal (such as command prompt, powershell, iTerm, etc.) login to github docker hub using following command, **replace `insert_your_git_name` with your github name**:

```
docker login ghcr.io -u insert_your_git_name
```

> You will be prompted to provide password, for password you will use previously created Github Personal Access token


Once you successfully login to docker, pull the `neat` docker image from github using following command:

```
docker pull ghcr.io/aker-information-model/neat:latest
```

> The above actions need to be done only either when you are creating your personal access token or whenever that token expires


If this was successful proceed and clone this repository to your local machine:

```
git clone https://github.com/aker-information-model/neat-docker.git
```


Go to subdirectory of the cloned repository through terminal:
```
cd neat-docker/docker
```

and create folder `data` and remember where that folder is as it will be useful to inspect content `NEAT` will create in it:

```
mkdir data
```

> The above actions need to be done only once



Finally, start `NEAT` by executing this command in terminal:

```
docker-compose up -d
```

In browser visit following address http://localhost:8000/, you should see `NEAT` running:

![](./figs/neat-walkthrough.gif)

As animated gif above shows above, click on `Workflow selector` and select `github2github` workflow and press button `START WORKFLOW`. If everything is right you should see all green in the status on the right.

Also you can inspect Docker Desktop app, which will show you status of `NEAT` container (i.e. whether it is running or not). Through Docker Desktop app you can stop, start, restart `NEAT` container. It is usually preferred way of dealing with docker containers for people not so familiar working in terminal. The below animated gif shows walkthrough Docker Desktop app on mac:

![](./figs/docker-app-walkthrough.gif)