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

FROM golang:1.22.0-alpine@sha256:8e96e6cff6a388c2f70f5f662b64120941fcd7d4b89d62fec87520323a316bd9 as builder
RUN apk add --no-cache ca-certificates git
RUN apk add build-base

# Set up build args for sl 
#  see: skaffold.env
ARG SL_APP=gcp_checkoutservice
ARG SL_BRANCH
ARG SL_BUILD
ENV SEALIGHTS_DISABLE_ON_INIT=false

WORKDIR /src

# restore dependencies
COPY go.mod go.sum ./
RUN go mod download

COPY . .

# Download the TWO golang agents. Note that these are OS/Arch specific, so we need to know what our host OS/Arch is. 
# OS_ARCH is one of: darwin-amd64, darwin-arm64, linux-amd64, linux-arm64
ENV OS_ARCH=linux-amd64

# First, grab the sealights-go-agent, unpack it, and rm the tar.gz
RUN wget -nv -O sealights-go-agent.tar.gz \
    https://agents.sealights.co/slgoagent/latest/slgoagent-${OS_ARCH}.tar.gz \
    && tar -xzf ./sealights-go-agent.tar.gz \
    && rm -f ./sealights-go-agent.tar.gz
# Then do that with the sealights-slcli
RUN wget -nv -O sealights-slcli.tar.gz \
    https://agents.sealights.co/slcli/latest/slcli-${OS_ARCH}.tar.gz \
    && tar -xzf ./sealights-slcli.tar.gz \
    && rm -f ./sealights-slcli.tar.gz

# Initialize the sl CLI
RUN ./slcli config init --lang go --token ./sltoken.txt

# Generate a sessionId
RUN ./slcli config create-bsid \
    --app ${SL_APP} \
    --branch ${SL_BRANCH} \
    --build ${SL_BUILD}

# Scan the build
RUN ./slcli scan \
    --bsid buildSessionId.txt \
    --path-to-scanner ./slgoagent \
    --workspacepath . \
    --scm none

# Skaffold passes in debug-oriented compiler flags
ARG SKAFFOLD_GO_GCFLAGS
RUN go build -gcflags="${SKAFFOLD_GO_GCFLAGS}" -o /checkoutservice .

FROM alpine:3.19.1@sha256:c5b1261d6d3e43071626931fc004f70149baeba2c8ec672bd4f27761f8e1ad6b
RUN apk add --no-cache ca-certificates

WORKDIR /src
COPY --from=builder /checkoutservice /src/checkoutservice

# Definition of this variable is used by 'skaffold debug' to identify a golang binary.
# Default behavior - a failure prints a stack trace for the current goroutine.
# See https://golang.org/pkg/runtime/
ENV GOTRACEBACK=single

EXPOSE 5050
ENTRYPOINT ["/src/checkoutservice"]
