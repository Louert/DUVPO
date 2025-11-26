.PHONY: all install_pandoc install_latex build clean

MARKDOWN_DIR = MarkDown
OUTPUT = documentation.docx
#PANDOC_URL = https://github.com/jgm/pandoc/releases/download/3.1.9/pandoc-3.1.9-windows-x86_64.zip
#TINYTEX_URL = https://yihui.org/tinytex/install-bin-windows.bat
PANDOC_EXE = pandoc-3.1.9-windows-x86_64/pandoc.exe
PANDOC_EXISTS := $(shell where pandoc >nul 2>nul && echo yes || echo no)
LATEX_EXISTS := $(shell where pdflatex >nul 2>nul && echo yes || echo no)
PANDOC := $(if $(wildcard $(PANDOC_EXE)), $(PANDOC_EXE), pandoc)

all: build

build:
	@echo "Building documentation.docx..."
	$(PANDOC) --citeproc --bibliography $(MARKDOWN_DIR)/references.bib --resource-path=$(MARKDOWN_DIR) -f markdown -t docx -o $(OUTPUT) $(wildcard $(MARKDOWN_DIR)/*.md)

clean:
	del /Q $(OUTPUT) 2>nul || echo "Nothing to clean."