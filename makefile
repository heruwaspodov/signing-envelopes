# This will output the help for each task
.PHONY: help

help:
	@awk 'BEGIN {FS = ":.*?## "} /^[a-zA-Z_-]+:.*?## / {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}' $(MAKEFILE_LIST)

.DEFAULT_GOAL := help

# Passthrough .env file key val to makefile
ifneq (,$(wildcard ./.env))
    include .env
    export
    ENV_FILE_PARAM = --env-file .env
endif

# Local datadog-agent development operations
dd-agent-start:
	docker run -d --cgroupns host --name dd-agent-msign-be-dev --platform linux/amd64 -v /var/run/docker.sock:/var/run/docker.sock:ro -v /proc/:/host/proc/:ro -v /sys/fs/cgroup/:/host/sys/fs/cgroup:ro -p 8125:8125/udp -p 8126:8126/tcp -e DD_API_KEY=${DD_API_KEY} -e DD_APM_ENABLED=${DD_APM_ENABLED} -e DD_DOGSTATSD_NON_LOCAL_TRAFFIC=true gcr.io/datadoghq/agent:7

dd-agent-logs:
	docker logs -f dd-agent-msign-be-dev

dd-agent-stop:
	docker stop dd-agent-msign-be-dev
	docker rm dd-agent-msign-be-dev

