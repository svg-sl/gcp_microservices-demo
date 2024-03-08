# Copyright 2020 Google LLC
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#      http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

# Revert to python 3.10, 
# https://github.com/GoogleCloudPlatform/microservices-demo/commit/21b5bd604b6bf689164118963978cd61674a9e13#diff-6928607b5169ec56a4872cfe253b8eb6b897d017cc125ce5c7b1777bbb832b68m 

FROM python:3.10.13-slim@sha256:1d517e04d033a04d86f7de57bf41cae166ca362b37a1cb229e326bc1d754db55 as base

FROM base as builder

# Set our SL args
ARG SL_APP=gcp_recommendationservice
ARG SL_BRANCH
ARG SL_BUILD
# ARG SL_LABID

RUN apt-get -qq update \
    && apt-get install -y --no-install-recommends \
        wget g++ \
    && rm -rf /var/lib/apt/lists/*

# get packages
COPY requirements.txt .
RUN pip install -r requirements.txt
# # Install the agent from pypi -- 
# # we could also do this by adding it as a project dep so it installs with the prev step, I think?
# RUN pip install sealights-python-agent

FROM base
# Enable unbuffered logging
ENV PYTHONUNBUFFERED=1

# get packages
WORKDIR /recommendationservice

#bustcache
# Grab packages from builder
COPY --from=builder /usr/local/lib/python3.10/ /usr/local/lib/python3.10/

# Set our SL args
ARG SL_APP=gcp_recommendationservice
ARG SL_BRANCH
ARG SL_BUILD
# ARG SL_LABID

# Install the agent from pypi -- 
# we could also do this by adding it as a project dep so it installs with the prev step, I think?
RUN pip install sealights-python-agent

# Add the application
COPY . .

# Generate a session ID
RUN sl-python config --appname ${SL_APP} --branchname ${SL_BRANCH} --buildname ${SL_BUILD} --workspacepath . --tokenfile sltoken.txt 


RUN sl-python scan  --scm none --tokenfile sltoken.txt
# RUN sl-python scan --tokenfile sltoken.txt --buildsessionidfile buildSessionId.txt --labid ${SL_LABID}

# set listen port
ENV PORT "8080"
EXPOSE 8080

# ENTRYPOINT ["python", "recommendation_server.py"]

# The command to run the server with sl-python is:
# sl-python run python recommendation_server.py --labid ${SL_BUILD_SESSION_ID} --tokenfile sltoken.txt
# So we change our ENTRYPOINT to CMD

CMD sl-python run python recommendation_server.py --buildsessionidfile buildSessionId.txt --tokenfile sltoken.txt

# CMD sl-python run python recommendation_server.py --labid ${SL_LAB_ID} --token ${SL_TOKEN}

# CMD sl-python run python recommendation_server.py --labid ${SL_LABID} --tokenfile sltoken.txt