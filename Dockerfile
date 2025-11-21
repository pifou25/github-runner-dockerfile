
FROM ubuntu:24.04

ARG RUNNER_VERSION="2.329.0"
ARG ARCH="arm64"

# Prevents installdependencies.sh from prompting the user and blocking the image creation
ARG DEBIAN_FRONTEND=noninteractive

RUN apt update -y && apt upgrade -y && useradd -m docker
RUN apt install -y --no-install-recommends \
    curl jq build-essential libssl-dev libffi-dev python3 python3-venv python3-dev python3-pip libicu-dev

WORKDIR /home/docker
RUN mkdir actions-runner && cd actions-runner \
    && curl -O -L https://github.com/actions/runner/releases/download/v${RUNNER_VERSION}/actions-runner-linux-${ARCH}-${RUNNER_VERSION}.tar.gz \
    && tar xzf ./actions-runner-linux-${ARCH}-${RUNNER_VERSION}.tar.gz

RUN chown -R docker /home/docker && /home/docker/actions-runner/bin/installdependencies.sh

RUN sed -i 's/\x41\x00\x43\x00\x54\x00\x49\x00\x4F\x00\x4E\x00\x53\x00\x5F\x00\x52\x00\x45\x00\x53\x00\x55\x00\x4C\x00\x54\x00\x53\x00\x5F\x00\x55\x00\x52\x00\x4C\x00/\x41\x00\x43\x00\x54\x00\x49\x00\x4F\x>

COPY start.sh start.sh

# make the script executable
RUN chmod +x start.sh

# since the config and run script for actions are not allowed to be run by root,
# set the user to "docker" so all subsequent commands are run as the docker user
USER docker

ENTRYPOINT ["./start.sh"]
