SED_INPLACE = $(shell [[ "$$(uname)" == "Darwin" ]] && echo "sed -i ''" || echo "sed -i")

version: 
	@echo $$(grep -m 1 FROM Dockerfile | cut -d ':' -f 2) | sed 's%\/%_%g'

latest-vep-version:
	@curl -s https://api.github.com/repos/Ensembl/ensembl-vep/releases/latest | jq -r '.tag_name' | sed 's%\/%_%g'

build-local:
	@echo "Running tests..."
	docker build -t custom_vep:$$(make version) .
	@echo "Tests passed!"

update:
	@echo "Updating Dockerfile..."
	@old_version=$$(make --silent version); \
	new_version=$$(make --silent latest-vep-version); \
	$(SED_INPLACE) "s%$$old_version%$$new_version%1" Dockerfile

extract-so-terms:
	
	@echo "Extracting so terms from ensembl-variation"
	@./so_terms/extract_so_terms.pm

