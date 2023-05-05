FROM --platform=linux/amd64 cognite/neat as base

# Arguments for soure repo this are READ ONLY keys
ARG source_prv_key
ARG source_pub_key

# Arguments for output repo this are READ/WRITE keys
ARG output_prv_key
ARG output_pub_key

RUN apt update -y
RUN apt install -y git
RUN apt install -y openssh-server

# Authorize SSH Host
RUN mkdir -p /root/.ssh && \
    chmod 0700 /root/.ssh && \
    ssh-keyscan github.com > /root/.ssh/known_hosts

# SOURCE REPO KEYS
RUN echo "$source_prv_key" > /root/.ssh/source && \
    echo "$source_pub_key" > /root/.ssh/source.pub && \
    chmod 600 /root/.ssh/source && \
    chmod 600 /root/.ssh/source.pub


# Add deploy key config that will alow fetching from private repo on github
RUN touch /root/.ssh/config && \
    chmod 600 /root/.ssh/config && \
    echo "Host source" >> /root/.ssh/config && \
    echo "  HostName github.com" >> /root/.ssh/config && \
    echo "  AddKeysToAgent yes" >> /root/.ssh/config && \
    echo "  PreferredAuthentications publickey" >> /root/.ssh/config && \
    echo "  IdentityFile /root/.ssh/source" >> /root/.ssh/config && \
    echo "  " >> /root/.ssh/config

# OUTPUT REPO KEYS
RUN echo "$output_prv_key" > /root/.ssh/output && \
    echo "$output_pub_key" > /root/.ssh/output.pub && \
    chmod 600 /root/.ssh/output && \
    chmod 600 /root/.ssh/output.pub

# Add deploy key config that will alow fetching from private repo on github
RUN echo "Host output" >> /root/.ssh/config && \
    echo "  HostName github.com" >> /root/.ssh/config && \
    echo "  AddKeysToAgent yes" >> /root/.ssh/config && \
    echo "  PreferredAuthentications publickey" >> /root/.ssh/config && \
    echo "  IdentityFile /root/.ssh/output" >> /root/.ssh/config


# Test clone of source and output repos
RUN git clone git@source:aker-information-model/neat-source.git ./source
RUN git clone git@output:aker-information-model/neat-output.git ./output


WORKDIR /app
# Default config file
ENV NEAT_CONFIG_PATH=/app/data/config.yaml

# Set the default command to run the application
CMD ["uvicorn", "--host","0.0.0.0", "cognite.neat.explorer.explorer:app"]
