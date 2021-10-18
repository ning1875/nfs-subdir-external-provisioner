# Copyright 2017-2020 The Kubernetes Authors.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

FROM golang:1.16-alpine as builder
WORKDIR /usr/src/app
RUN sed -i 's/dl-cdn.alpinelinux.org/mirrors.aliyun.com/g' /etc/apk/repositories && \
  apk add --no-cache upx ca-certificates tzdata
COPY ./go.mod ./
COPY ./go.sum ./
RUN go mod download
COPY . .

RUN CGO_ENABLED=0 go build -a -ldflags ' -X main.version= -extldflags "-static"' -o nfs-subdir-external-provisioner ./cmd/nfs-subdir-external-provisioner

FROM gcr.io/distroless/static:latest
COPY --from=builder /usr/share/zoneinfo/Asia/Shanghai /etc/localtime
COPY --from=builder /etc/ssl/certs/ca-certificates.crt /etc/ssl/certs/
COPY --from=builder /usr/src/app/nfs-subdir-external-provisioner /nfs-subdir-external-provisioner


LABEL maintainers="Kubernetes Authors"
LABEL description="NFS subdir external provisioner"
ENTRYPOINT ["/nfs-subdir-external-provisioner"]
