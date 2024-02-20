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

FROM node:20.11.0-alpine@sha256:2f46fd49c767554c089a5eb219115313b72748d8f62f5eccb58ef52bc36db4ad as base

FROM base as builder

# Later, when we parameterize the build:
# ARG SEALIGHTS_TOKEN
# ARG BUILD_NAME
# ARG SVGBRANCH
# ENV BRANCH=devel

# Some packages (e.g. @google-cloud/profiler) require additional
# deps for post-install scripts
RUN apk add --update --no-cache \
    python3 \
    make \
    g++

WORKDIR /usr/src/app

COPY package*.json ./

RUN npm install --only=production

# install slnodejs
RUN npm install slnodejs

FROM base

WORKDIR /usr/src/app

COPY --from=builder /usr/src/app/node_modules ./node_modules

COPY . .

# turn up sl debug
ENV NODE_DEBUG=sl

ARG SL_APP=gcp_currencyservice
ARG SL_BRANCH
ARG SL_BUILD

# slnodejs config - get the build session id
RUN ./node_modules/.bin/slnodejs config \
    --tokenfile sltoken.txt \
    --appname ${SL_APP} \
    --build ${SL_BUILD} \
    --branch ${SL_BRANCH} 
    

# slnodejs scan - do the build scan
RUN ./node_modules/.bin/slnodejs scan \
    --tokenfile sltoken.txt \
    --buildsessionidfile buildSessionId \
    --workspacepath "." \
    --scm none

EXPOSE 7000

# ENTRYPOINT [ "node", "server.js" ]

# Run the app with slnodejs like:
# ./node_modules/.bin/slnodejs run --tokenfile sltoken.txt --buildsessionidfile buildSessionId --workspacepath . -- server.js

ENTRYPOINT [ "./node_modules/.bin/slnodejs", "run", "--tokenfile", "sltoken.txt", "--buildsessionidfile", "buildSessionId", "--workspacepath", ".", "--", "server.js" ]

