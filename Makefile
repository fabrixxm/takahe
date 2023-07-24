.PHONY: image docs compose_build compose_up compose_down

image:
	docker build -t takahe -f docker/Dockerfile .

docs:
	cd docs/ && make html

compose_build:
	docker-compose -f docker/docker-compose.yml build

compose_up:
	docker-compose -f docker/docker-compose.yml up

compose_down:
	docker-compose -f docker/docker-compose.yml down

# Development Setup
.venv:
	python3 -m venv .venv
	.venv/bin/python3 -m pip install -r requirements-dev.txt

.git/hooks/pre-commit: .venv
	.venv/bin/python3 -m pre_commit install

.env:
	cp development.env .env

_PHONY: setup_local
setup_local: .venv .env .git/hooks/pre-commit

_PHONY: startdb stopdb
startdb:
	podman-compose -f docker/docker-compose.yml up db -d

stopdb:
	podman-compose -f docker/docker-compose.yml stop db

_PHONY: createsuperuser
createsuperuser:
	.venv/bin/python3 -m manage createsuperuser

_PHONY: test
test: setup_local
	.venv/bin/python3 -m pytest

# Active development
_PHONY: migrations server stator
migrations:
	.venv/bin/python3 -m manage migrate

runserver:
	.venv/bin/python3 -m manage runserver

runstator:
	.venv/bin/python3 -m manage runstator
