#!/bin/sh

set -ev

Rscript -e "bookdown::render_book('website/index.Rmd', 'bookdown::gitbook', output_dir='docs/')"
Rscript -e "bookdown::render_book('website/index.Rmd', 'bookdown::pdf_book', output_dir='docs/')"
Rscript -e "bookdown::render_book('website/index.Rmd', 'bookdown::epub_book', output_dir='docs/')"

