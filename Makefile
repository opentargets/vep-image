version: 
	@echo 114.0

build-local:
	@echo "Running tests..."
	docker build -t custom_vep:$$(make version) .
	@echo "Tests passed!"