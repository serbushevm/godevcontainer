ARG BASEDEV_VERSION=v0.26.0
ARG ALPINE_VERSION=3.22
ARG GO_VERSION=1.23
ARG GOMODIFYTAGS_VERSION=v1.17.0
ARG GOPLAY_VERSION=v1.0.0
ARG GOTESTS_VERSION=v1.6.0
ARG DLV_VERSION=v1.23.1
ARG MOCKERY_VERSION=v2.46.2
ARG GOMOCK_VERSION=v1.6.0
ARG MOCKGEN_VERSION=v1.6.0
ARG GOPLS_VERSION=v0.16.2
ARG GOFUMPT_VERSION=v0.7.0
ARG GOLANGCILINT_VERSION=v1.63.4
ARG IMPL_VERSION=v1.2.0
ARG GOPKGS_VERSION=v2.1.2
ARG KUBECTL_VERSION=v1.31.1
ARG STERN_VERSION=v1.31.0
ARG KUBECTX_VERSION=v0.9.5
ARG KUBENS_VERSION=v0.9.5
ARG HELM_VERSION=v3.16.2

ARG NODE_VERSION=22.16

FROM golang:${GO_VERSION}-alpine${ALPINE_VERSION} AS go
# FROM node:${NODE_VERSION}-alpine${ALPINE_VERSION} AS node-runtime
FROM qmcgaw/binpot:gomodifytags-${GOMODIFYTAGS_VERSION} AS gomodifytags
FROM qmcgaw/binpot:goplay-${GOPLAY_VERSION} AS goplay
FROM qmcgaw/binpot:gotests-${GOTESTS_VERSION} AS gotests
FROM qmcgaw/binpot:dlv-${DLV_VERSION} AS dlv
FROM qmcgaw/binpot:mockery-${MOCKERY_VERSION} AS mockery
FROM qmcgaw/binpot:gomock-${GOMOCK_VERSION} AS gomock
FROM qmcgaw/binpot:mockgen-${MOCKGEN_VERSION} AS mockgen
FROM qmcgaw/binpot:gopls-${GOPLS_VERSION} AS gopls
FROM qmcgaw/binpot:gofumpt-${GOFUMPT_VERSION} AS gofumpt
FROM qmcgaw/binpot:golangci-lint-${GOLANGCILINT_VERSION} AS golangci-lint
FROM qmcgaw/binpot:impl-${IMPL_VERSION} AS impl
FROM qmcgaw/binpot:gopkgs-${GOPKGS_VERSION} AS gopkgs
FROM qmcgaw/binpot:kubectl-${KUBECTL_VERSION} AS kubectl
FROM qmcgaw/binpot:stern-${STERN_VERSION} AS stern
FROM qmcgaw/binpot:kubectx-${KUBECTX_VERSION} AS kubectx
FROM qmcgaw/binpot:kubens-${KUBENS_VERSION} AS kubens
FROM qmcgaw/binpot:helm-${HELM_VERSION} AS helm

FROM ghcr.io/serbushevm/basedevcontainer:alpine
ARG CREATED
ARG COMMIT
ARG VERSION=local
LABEL \
    org.opencontainers.image.authors="quentin.mcgaw@gmail.com" \
    org.opencontainers.image.created=$CREATED \
    org.opencontainers.image.version=$VERSION \
    org.opencontainers.image.revision=$COMMIT \
    org.opencontainers.image.url="https://github.com/qdm12/godevcontainer" \
    org.opencontainers.image.documentation="https://github.com/qdm12/godevcontainer" \
    org.opencontainers.image.source="https://github.com/qdm12/godevcontainer" \
    org.opencontainers.image.title="Go Dev container Alpine" \
    org.opencontainers.image.description="Go development container for Visual Studio Code Dev Containers development"
# Node.js setup
# COPY --from=node-runtime /usr/local/bin/node          /usr/local/bin/
# COPY --from=node-runtime /usr/local/bin/npm           /usr/local/bin/
# COPY --from=node-runtime /usr/local/bin/npx           /usr/local/bin/
# COPY --from=node-runtime /usr/local/bin/corepack      /usr/local/bin/
# COPY --from=node-runtime /usr/local/lib/node_modules  /usr/local/lib/node_modules
# COPY --from=node-runtime /usr/local/include/node      /usr/local/include/node
# ENV COREPACK_ENABLE=1
# Go setup
COPY --from=go /usr/local/go /usr/local/go
ENV GOPATH=/go
ENV PATH=$GOPATH/bin:/usr/local/go/bin:$PATH \
    CGO_ENABLED=0 \
    GO111MODULE=on
WORKDIR $GOPATH
# Install Alpine packages (g++ for race testing)
RUN apk add -q --update --progress --no-cache g++
# Shell setup
COPY shell/.zshrc-specific shell/.welcome.sh /root/

COPY --from=gomodifytags /bin /go/bin/gomodifytags
COPY --from=goplay  /bin /go/bin/goplay
COPY --from=gotests /bin /go/bin/gotests
COPY --from=dlv /bin /go/bin/dlv
COPY --from=mockery /bin /go/bin/mockery
COPY --from=gomock /bin /go/bin/gomock
COPY --from=mockgen /bin /go/bin/mockgen
COPY --from=gopls /bin /go/bin/gopls
COPY --from=gofumpt /bin /go/bin/gofumpt
COPY --from=golangci-lint /bin /go/bin/golangci-lint
COPY --from=impl /bin /go/bin/impl
COPY --from=gopkgs /bin /go/bin/gopkgs

# Extra binary tools
COPY --from=kubectl /bin /usr/local/bin/kubectl
COPY --from=stern /bin /usr/local/bin/stern
COPY --from=kubectx /bin /usr/local/bin/kubectx
COPY --from=kubens /bin /usr/local/bin/kubens
COPY --from=helm /bin /usr/local/bin/helm
