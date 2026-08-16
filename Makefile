.PHONY: build-vuln build-hardened scan lint clean

build-vuln:
	docker compose -f docker-compose.vulnerable.yml build

build-hardened:
	docker compose -f docker-compose.hardened.yml build

scan:
	bash scanning/run-trivy.sh

lint:
	bash tests/run-hadolint.sh

clean:
	docker compose -f docker-compose.vulnerable.yml down --rmi local -v || true
	docker compose -f docker-compose.hardened.yml down --rmi local -v || true
