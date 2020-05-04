FROM python:3.8.1-buster
ENV PYTHONUNBUFFERED=1
ENV PIP_NO_CACHE_DIR=off

RUN apt-get update 
# groff and less are needed for aws
RUN apt-get install -y \
  jq \
  groff \
  less

# install gcp
ENV GOOGLE_CLOUD_SDK_VERSION 282.0.0
RUN mkdir -p /gcp
RUN cd /gcp && \
  curl https://dl.google.com/dl/cloudsdk/channels/rapid/downloads/google-cloud-sdk-${GOOGLE_CLOUD_SDK_VERSION}-linux-x86_64.tar.gz \
    -o google-cloud-sdk.tar.gz && \
  tar xf google-cloud-sdk.tar.gz && \
  rm google-cloud-sdk.tar.gz
RUN /gcp/google-cloud-sdk/install.sh -q
ENV PATH="/gcp/google-cloud-sdk/bin/:${PATH}"

# install aws
RUN mkdir -p /aws
RUN cd /aws && \
    curl https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip \
      -o awscliv2.zip && \
    unzip awscliv2.zip && \
    rm awscliv2.zip
RUN /aws/aws/install

# install pipenv
ENV PIPENV_INSTALL_VERSION=2018.11.26
RUN pip install pipenv==${PIPENV_INSTALL_VERSION}

WORKDIR /app
ENV PYTHONPATH=/app

ENV PIPENV_SYSTEM=1
ENV PIPENV_CLEAR=1
ENV PIPENV_KEEP_OUTDATED=1
ARG PIPENV_DEV=0
ENV PIPENV_DEV=${PIPENV_DEV}
COPY Pipfile .
COPY Pipfile.lock .
RUN pipenv install --deploy

COPY ./gcp.sh ./
COPY ./entrypoint.sh ./
ENTRYPOINT ["./entrypoint.sh"] 
COPY ./tpt ./tpt
COPY ./sql ./sql
