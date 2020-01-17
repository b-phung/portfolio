build: Dockerfile
	docker build -t mydocker . && touch $@
	python scripts/wrangle.py

# gen_figures: data/zip.csv data/year.csv data/hpi_wrangled.csv scripts/visualization.R
# 	docker run -it --rm -v $(shell pwd):/workdir -w /workdir \
# 	mydocker Rscript scripts/visualization.R