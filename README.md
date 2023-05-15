# NEAT Config

Docker image tailored for AKSO needs


Follow [instruction](https://docs.github.com/en/enterprise-server@3.4/authentication/keeping-your-account-and-data-secure/creating-a-personal-access-token) and create Github Personal Token.

Store Personal Token somewhere secure!

Then in terminal execute following commands (replace necessary value):

```
export GIT_PERSONAL_TOKEN=insert_your_personal_token
echo $GIT_PERSONAL_TOKEN | docker login ghcr.io -u inser_your_git_name --password-stdin
docker pull ghcr.io/aker-information-model/neat:latest
```

If this was successful proceed and clone this repository to your local machine:

```
git clone https://github.com/aker-information-model/neat-config.git
```

Go to subdirectory of the cloned repository and make folder `data`:
```
cd neat-config/docker
mkdir data
```

Create docker volume where NEAT data will be stored and link it to `data` folder :
```
docker volume create --name neat-volume --opt type=none --opt device=${PWD}/data --opt o=bind
```



Finally, start neat by executing command:

```
docker-compose up -d
```