# NEAT Config

Docker image tailored for AKSO needs

Clone this repository to your local machine and cd to created folder:

```
git clone https://github.com/aker-information-model/neat-config.git
cd neat-config
```

After cloning generate two sets of private and public keys, where:
1. One set will be used to create read-only Deploy key for [neat-source repository](https://github.com/aker-information-model/neat-source), store these keys under name `neat-source` in `~/.ssh/` folder
2. Second set will be used to create read-write Deploy key for [neat-output repository](https://github.com/aker-information-model/neat-output), store these keys under name `neat-output` in `~/.ssh/` folder

Follow step described [here ](https://dylancastillo.co/how-to-use-github-deploy-keys/) on how to generate keys and how to insert them to the above repository. Though also consult following [Medium Post](https://medium.com/@dustinfarris/managing-multiple-github-deploy-keys-on-a-single-server-f81f8f23e473)


Once the above steps are completed you are ready to make AKSO specific docker image of NEAT, while in terminal and in the folder created after running `git clone ...` execute following command:

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