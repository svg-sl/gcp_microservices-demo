# Copyright 2021 Google LLC
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

# https://mcr.microsoft.com/product/dotnet/sdk
FROM mcr.microsoft.com/dotnet/sdk:8.0.101@sha256:8e77ad6fb7c33c17f026424d3bef05ea2ee15d1621e28f312adeab4dc1005866 as builder

# Later, when we parameterize the build:
# ARG SEALIGHTS_TOKEN
# ARG BUILD_NAME
# ENV SEALIGHTS_NODE_AGENT=slnodejs
# ARG BRANCH
ENV BRANCH=devel

WORKDIR /app
COPY cartservice.csproj .
RUN dotnet restore cartservice.csproj \
    -r linux-musl-x64
COPY . .
RUN dotnet publish cartservice.csproj \
    -p:PublishSingleFile=true \
    -r linux-musl-x64 \
    --self-contained true \
    -p:PublishTrimmed=True \
    -p:TrimMode=Full \
    -c release \
    -o /cartservice \
    --no-restore

# This might be overkill, but in the interest of organization:
WORKDIR /sl
# Download the agent
RUN wget -nv -O sealights-dotnet-agent-linux.tar.gz https://agents.sealights.co/dotnetcore/latest/sealights-dotnet-agent-linux-self-contained.tar.gz
RUN mkdir sl-dotnet-agent && tar -xzf ./sealights-dotnet-agent-linux.tar.gz --directory ./sl-dotnet-agent
RUN echo "[Sealights] .NetCore Agent version is: `cat ./sl-dotnet-agent/version.txt`"

# grab the token
COPY sltoken.txt .

# Generate a Session ID
RUN dotnet /sl/sl-dotnet-agent/SL.DotNet.dll  config \
    --appName "gcp_cartservice" \
    --branchName "devel" \
    --buildName  `date +"%y%m%d_%H%M"` \
    --includeNamespace "*.service*" \
    --tokenFile /sl/sltoken.txt \
    --identifyMethodsByFqn

# Scan the binaries
RUN dotnet /sl/sl-dotnet-agent/SL.DotNet.dll scan \
    --buildSessionIdFile buildSessionId \
    --workspacePath /app \
    --ignoreGeneratedCode true \
    --tokenFile /sl/sltoken.txt


# https://mcr.microsoft.com/product/dotnet/runtime-deps
FROM mcr.microsoft.com/dotnet/runtime-deps:8.0.1-alpine3.18-amd64@sha256:6995921cfa678fe55dfa02c455f379f31bdd589a6eaad6bb714ff82deb441f8f

# Now, download the alpine agent, also...
# TODO: ask Jason about whether or not this is how I should be doing this
WORKDIR /sl
COPY --from=builder /sl/buildSessionId  /sl/buildSessionId 
COPY --from=builder /sl/sltoken.txt  /sl/sltoken.txt 
RUN mkdir agent
RUN wget -nv -O sealights-dotnet-agent-alpine.tar.gz https://agents.sealights.co/dotnetcore/latest/sealights-dotnet-agent-alpine-self-contained.tar.gz
RUN tar -xzf ./sealights-dotnet-agent-alpine.tar.gz --directory /sl/agent
RUN chmod -R 777 /sl


WORKDIR /app
COPY --from=builder /cartservice .
EXPOSE 7070
ENV DOTNET_EnableDiagnostics=0 \
    ASPNETCORE_HTTP_PORTS=7070
USER 1000
# ENTRYPOINT ["/app/cartservice"]
# ENTRYPOINT ["sleep", INFINITY]

CMD /sl/agent/SL.DotNet run --buildSessionIdFile /sl/buildSessionId --target /app/cartservice --tokenFile /sl/sltoken.txt
