FROM golang:1.14.13-stretch

ENV GLIDE_VERSION=0.13.3 \
  DEP_VERSION=0.5.4 \
  GLIDE_SHA256_SUM=ba5619955a28d7931a9ae38d095fc5fa5acc28e77abc8737a8136c652d9cbb38 \
  DEP_SHA256_SUM=9507d8826574a5b25cf069ab9311793e5d5fc88bba3bdfd02131fae8f50ed1bc

RUN set -x \
 && apt-get update \
 && apt-get install -y --no-install-recommends btrfs-tools \
 # install glide
 && wget https://github.com/Masterminds/glide/releases/download/v${GLIDE_VERSION}/glide-v${GLIDE_VERSION}-linux-amd64.tar.gz \
 && echo "${GLIDE_SHA256_SUM} glide-v${GLIDE_VERSION}-linux-amd64.tar.gz" | sha256sum -c - \
 && tar xvfz glide-v${GLIDE_VERSION}-linux-amd64.tar.gz -C /usr/local/bin --strip-components=1 linux-amd64/glide \
 && rm glide-v${GLIDE_VERSION}-linux-amd64.tar.gz \
 && chmod +x /usr/local/bin/glide \
 # install dep
 && curl -f https://raw.githubusercontent.com/golang/dep/v${DEP_VERSION}/install.sh -o dep-install-v${DEP_VERSION}.sh \
 && echo "${DEP_SHA256_SUM} dep-install-v${DEP_VERSION}.sh" | sha256sum -c - \
 && chmod +x dep-install-v${DEP_VERSION}.sh \
 && ./dep-install-v${DEP_VERSION}.sh \
 && rm dep-install-v${DEP_VERSION}.sh \
 # create jenkins passwd entries, because some commands fail if there is no entry for the uid
 # we create multiple entries, because we do not know the uid of the jenkins user
 && for i in $(seq 1000 1010); do useradd -u ${i} -s /bin/bash -m "jenkins${i}"; done \
 # install go tools
 && go get github.com/mitchellh/gox \
 && go get github.com/tebeka/go2xunit \
 && go get github.com/jstemmer/go-junit-report \
 && go get github.com/alecthomas/gometalinter \
 && GO111MODULE=on go get github.com/reviewdog/reviewdog/cmd/reviewdog@v0.9.17 \
 && GO111MODULE=on go get github.com/golangci/golangci-lint/cmd/golangci-lint@v1.26.0 \
 && go get github.com/gobuffalo/packr/packr \ 
 && gometalinter --install \
 # install frontend build tools
 && curl -sL https://deb.nodesource.com/setup_8.x | bash \
 && apt-get install -y nodejs \
 && npm install -g npm bower gulp-cli yarn \
 # cleanup
 && rm -rf /var/lib/apt/lists/* \
 && chown -R 1000:1000 /go
