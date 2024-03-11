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

FROM python:3.10.8-slim@sha256:abf96998af340975c26177b900c10cfb40716c985325303c063736f0f5cf3171 as base

FROM base as builder

# Set our SL args
ARG SL_APP=gcp_emailservice
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


FROM base
# Enable unbuffered logging
ENV PYTHONUNBUFFERED=1
# Enable Profiler
ENV ENABLE_PROFILER=1

WORKDIR /email_server

# Grab packages from builder
COPY --from=builder /usr/local/lib/python3.10/ /usr/local/lib/python3.10/

# Set our SL args
ARG SL_APP=gcp_emailservice
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

EXPOSE 8080
# ENTRYPOINT [ "python", "email_server.py" ]

# Switch our ENTRYPOINT to a CMD
# The command to run the emailserver with sl-python is:
CMD sl-python run python email_server.py --buildsessionidfile buildSessionId.txt --tokenfile sltoken.txt