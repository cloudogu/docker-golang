FROM golang:1.10.2-stretch

ENV GLIDE_VERSION=0.13.1

RUN apt-get update \
 && apt-get install -y --no-install-recommends btrfs-tools \

 # install glide
 && wget https://github.com/Masterminds/glide/releases/download/v${GLIDE_VERSION}/glide-v${GLIDE_VERSION}-linux-amd64.tar.gz \
 && tar xvfz glide-v${GLIDE_VERSION}-linux-amd64.tar.gz -C /usr/local/bin --strip-components=1 linux-amd64/glide \
 && rm glide-v${GLIDE_VERSION}-linux-amd64.tar.gz \
 && chmod +x /usr/local/bin/glide \

 # create jenkins passwd entries, because some commands fail if there is no entry for the uid
 # we create multiple entries, because we do not know the uid of the jenkins user
 && for i in $(seq 1000 1010); do useradd -u ${i} -s /bin/bash "jenkins${i}"; done \

 # install go tools
 && go get github.com/tebeka/go2xunit \
 && go get github.com/alecthomas/gometalinter \
 && go get github.com/haya14busa/reviewdog/cmd/reviewdog \
 && gometalinter --install \


 # install frontend build tools
 && curl -sL https://deb.nodesource.com/setup_6.x | bash \
 && apt-get install -y nodejs \
 && npm install -g npm bower gulp-cli yarn \

 # cleanup
 && rm -rf /var/lib/apt/lists/*
