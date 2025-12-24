.PHONY: all check build clean

# -------- Пути --------
MARKDOWN_DIR = MarkDown
SECTIONS_DIR = $(MARKDOWN_DIR)/sections

OUTPUT = documentation.docx
REFERENCE_DOC = reference.docx

# Pandoc
PANDOC_DIR = D:/DUVPO/DUVPO/pandoc
PANDOC = $(PANDOC_DIR)/pandoc.exe
CROSSREF = $(PANDOC_DIR)/pandoc-crossref.exe

# Metadata / bibliography
YAML = $(MARKDOWN_DIR)/metadata.yaml
BIB  = $(MARKDOWN_DIR)/references.bib
CSL_FILE = gost-r-7-0-5-2008-numeric.csl

# -------- Исходники --------
SOURCES = \
	$(SECTIONS_DIR)/01-title.md \
	$(SECTIONS_DIR)/02-introduction.md \
	$(SECTIONS_DIR)/03-methodology.md \
	$(SECTIONS_DIR)/04-methods.md \
	$(SECTIONS_DIR)/05-results.md \
	$(SECTIONS_DIR)/06-conclusions.md \
	$(SECTIONS_DIR)/07-references.md \
	$(SECTIONS_DIR)/08-contacts.md

# -------- Цели --------
all: check build

check:
	@echo Checking environment...
	@if not exist "$(PANDOC)" (echo ERROR: pandoc.exe not found & exit 1)
	@if not exist "$(CROSSREF)" (echo ERROR: pandoc-crossref.exe not found & exit 1)
	@if not exist "$(YAML)" (echo ERROR: metadata.yaml not found & exit 1)
	@if not exist "$(BIB)" (echo ERROR: references.bib not found & exit 1)

	@if not exist "$(CSL_FILE)" echo Downloading CSL...
	@if not exist "$(CSL_FILE)" powershell -Command "Invoke-WebRequest -Uri 'https://raw.githubusercontent.com/citation-style-language/styles/master/gost-r-7-0-5-2008-numeric.csl' -OutFile '$(CSL_FILE)'"

	@for %%f in ($(SOURCES)) do @if not exist "%%f" (echo ERROR: File %%f not found & exit 1)

	@if not exist "$(REFERENCE_DOC)" (echo ERROR: reference.docx not found. Run Python script first. & exit 1)

	@echo OK.

build:
	@echo Building $(OUTPUT)...
	"$(PANDOC)" $(SOURCES) \
	--metadata-file="$(YAML)" \
	--filter="$(CROSSREF)" \
	--citeproc \
	--bibliography="$(BIB)" \
	--csl="$(CSL_FILE)" \
	--resource-path=$(MARKDOWN_DIR) \
	--reference-doc="$(REFERENCE_DOC)" \
	-f markdown \
	-t docx \
	-s \
	-o "$(OUTPUT)"
	@echo Done: $(OUTPUT)

clean:
	@echo Cleaning...
	@if exist "$(OUTPUT)" del "$(OUTPUT)"
