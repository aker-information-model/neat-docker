# NEAT Config

Docker image tailored for AKSO needs

Clone this repository to your local machine and cd to created folder:

```
git clone https://github.com/aker-information-model/neat-config.git
cd neat-config
```

After cloning generate two sets of private and public keys:
```
ssh-keygen -t rsa -f ~/.ssh/neat-source -C "aker-information-model neat-source"
ssh-keygen -t rsa -f ~/.ssh/neat-output -C "aker-information-model neat-source"
```

Cat the public keys and copy/paste them into each repo’s respective GitHub deploy key:
```
cat ~/.ssh/neat-source.pub
cat ~/.ssh/neat-output.pub
```

where:

1. `neat-source.pub` should be used as read-only Deploy key for [neat-source repository](https://github.com/aker-information-model/neat-source)
2. `neat-output.pub` should be used as read/write Deploy key for [neat-output repository](https://github.com/aker-information-model/neat-output)


Once the above steps are completed you are ready to make AKSO specific docker image of NEAT. While in the terminal and in the folder created after running `git clone ...` execute following command:

```
docker build -t akso/neat:latest --build-arg source_prv_key="$(cat ~/.ssh/neat-source)" --build-arg source_pub_key="$(cat ~/.ssh/neat-source.pub)" --build-arg output_prv_key="$(cat ~/.ssh/neat-output)" --build-arg output_pub_key="$(cat ~/.ssh/neat-output.pub)" .
```

Once docker image is created it is necessary to create `neat-volume` through which data contained in NEAT will accessible:

```
cd docker
mkdir data
docker volume create --name neat-volume --opt type=none --opt device=${PWD}/data --opt o=bind
```

Now you are ready to start NEAT using command:

```
docker-compose up -d
```