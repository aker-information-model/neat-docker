# NEAT Config

Hosting Docker file tailored for AKSO needs


To make docker image we first need to generate two sets of private and public keys, where:
1. One set will be used to create read-only Deploy key for [neat-source repository](https://github.com/aker-information-model/neat-source), store these keys under name `source` in `~/.ssh/` folder
2. Second set will be used to create read-write Deploy key for [neat-output repository](https://github.com/aker-information-model/neat-output), store these keys under name `output` in `~/.ssh/` folder

Follow step described [here ](https://dylancastillo.co/how-to-use-github-deploy-keys/) on how to generate keys and how to insert them to the above repository.

Under assumption that you have installed docker on your computer, execute following command in terminal to generate docker image:

```
docker build -t akso/neat:latest --build-arg source_prv_key="$(cat ~/.ssh/source)" --build-arg source_pub_key="$(cat ~/.ssh/source.pub)" --build-arg output_prv_key="$(cat ~/.ssh/output)" --build-arg output_pub_key="$(cat ~/.ssh/output.pub)" .
```