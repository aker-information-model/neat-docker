FROM --platform=linux/amd64 cognite/neat as base

# Arguments for soure repo this are READ ONLY keys
ARG source_prv_key
ARG source_pub_key

# Arguments for output repo this are READ/WRITE keys
ARG output_prv_key
ARG output_pub_key

# Copy AKSO specific workflow
COPY workflows/github2github /app/data/workflows/github2github
RUN chmod -R 777 /app/data/workflows/

RUN apt update -y
RUN apt install -y git
RUN apt install -y openssh-server

# Authorize SSH Host
RUN mkdir -p /root/.ssh && \
    chmod 0700 /root/.ssh && \
    ssh-keyscan github.com > /root/.ssh/known_hosts

# SOURCE REPO KEYS
RUN echo "$source_prv_key" > /root/.ssh/neat-source && \
    echo "$source_pub_key" > /root/.ssh/neat-source.pub && \
    chmod 600 /root/.ssh/neat-source && \
    chmod 600 /root/.ssh/neat-source.pub


# Add deploy key config that will alow fetching from private repo on github
RUN touch /root/.ssh/config && \
    chmod 600 /root/.ssh/config && \
    echo "Host neat-source" >> /root/.ssh/config && \
    echo "  HostName github.com" >> /root/.ssh/config && \
    echo "  User git" >> /root/.ssh/config && \
    echo "  IdentityFile /root/.ssh/neat-source" >> /root/.ssh/config && \
    echo "  " >> /root/.ssh/neat-source

# OUTPUT REPO KEYS
RUN echo "$output_prv_key" > /root/.ssh/neat-output && \
    echo "$output_pub_key" > /root/.ssh/neat-output.pub && \
    chmod 600 /root/.ssh/neat-output && \
    chmod 600 /root/.ssh/neat-output.pub

# Add deploy key config that will alow fetching from private repo on github
RUN echo "Host neat-output" >> /root/.ssh/config && \
    echo "  HostName github.com" >> /root/.ssh/config && \
    echo "  User git" >> /root/.ssh/config && \
    echo "  IdentityFile /root/.ssh/neat-output" >> /root/.ssh/config

# Configuring default git user
RUN git config --global user.name "NEAT"
RUN git config --global user.email "neat@cognite.com"

# Test clone of source and output repos
RUN git clone git@neat-source:aker-information-model/neat-source.git ./data/source
RUN git clone git@neat-output:aker-information-model/neat-output.git ./data/output

# Remove cloned source and output repos
RUN rm -rf ./data/source
RUN rm -rf ./data/output

WORKDIR /app
# Default config file
ENV NEAT_CONFIG_PATH=/app/data/config.yaml

# Set the default command to run the application
CMD ["uvicorn", "--host","0.0.0.0", "cognite.neat.explorer.explorer:app"]
