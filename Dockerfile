ARG ALPINE_VERSION=3.13.5

FROM alpine:${ALPINE_VERSION} as kubectl
ARG KUBECTL_VERSION=1.20.5
ARG KUBECTL_SHA=7f9dbb80190945a5077dc5f4230202c22f68f9bd7f20c213c3cf5a74abf55e56
RUN apk add --no-cache curl
WORKDIR /app
RUN curl -fsSLO https://storage.googleapis.com/kubernetes-release/release/v${KUBECTL_VERSION}/bin/linux/amd64/kubectl
RUN echo "${KUBECTL_SHA}  kubectl" | sha256sum -c
RUN chmod +x kubectl

FROM alpine:${ALPINE_VERSION} as aws-iam-authenticator
ARG AWS_IAM_AUTHENTICATOR_VERSION=1.21.2/2021-07-05
ARG AWS_IAM_AUTHENTICATOR_SHA=fe958eff955bea1499015b45dc53392a33f737630efd841cd574559cc0f41800
RUN apk add --no-cache curl
WORKDIR /app
RUN curl -fsSLO https://amazon-eks.s3.us-west-2.amazonaws.com/$AWS_IAM_AUTHENTICATOR_VERSION/bin/linux/amd64/aws-iam-authenticator
RUN echo "${AWS_IAM_AUTHENTICATOR_SHA}  aws-iam-authenticator" | sha256sum -c
RUN chmod +x aws-iam-authenticator

FROM alpine:${ALPINE_VERSION}
RUN apk add --no-cache py-pip
RUN pip install awscli
COPY --from=kubectl /app/kubectl /bin
COPY --from=aws-iam-authenticator /app/aws-iam-authenticator /bin
COPY entrypoint.sh /entrypoint.sh
ENTRYPOINT ["/entrypoint.sh"]
