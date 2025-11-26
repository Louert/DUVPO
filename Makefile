.PHONY: all install_pandoc build clean

MARKDOWN_DIR = MarkDown
OUTPUT = documentation.docx
PANDOC_URL = https://github.com/jgm/pandoc/releases/download/3.1.9/pandoc-3.1.9-windows-x86_64.zip
PANDOC_EXE = pandoc-3.1.9/pandoc.exe
PANDOC := $(PANDOC_EXE)

all: install_dependencies build

install_dependencies: install_pandoc

install_pandoc:
	@if exist $(PANDOC_EXE) (echo Pandoc already installed.) else (echo Downloading Pandoc... && powershell -Command "Invoke-WebRequest -Uri '$(PANDOC_URL)' -OutFile 'pandoc.zip'" && powershell -Command "Expand-Archive -Path 'pandoc.zip' -DestinationPath '.' -Force" && del pandoc.zip && echo Pandoc installed.)

build:
	@echo "Building documentation.docx..."
	$(PANDOC) --citeproc --bibliography $(MARKDOWN_DIR)/references.bib --resource-path=$(MARKDOWN_DIR) -f markdown -t docx -o $(OUTPUT) $(wildcard $(MARKDOWN_DIR)/*.md)

clean:
	del /Q $(OUTPUT) 2>nul || echo "Nothing to clean."
