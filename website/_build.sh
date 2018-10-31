#!/bin/sh

set -ev

cd website

Rscript -e "bookdown::render_book('index.Rmd', 'bookdown::gitbook', output_dir='../docs/')"
Rscript -e "bookdown::render_book('index.Rmd', 'bookdown::pdf_book', output_dir='../docs/')"
Rscript -e "bookdown::render_book('index.Rmd', 'bookdown::epub_book', output_dir='../docs/')"

cd ..
