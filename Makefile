.PHONY: all tools check build clean

# -------- Пути --------
MARKDOWN_DIR := MarkDown
SECTIONS_DIR := $(MARKDOWN_DIR)\sections

OUTPUT := documentation.docx
REFERENCE_DOC := reference.docx

# -------- Pandoc --------
PANDOC_DIR := pandoc
PANDOC := $(PANDOC_DIR)\pandoc.exe
CROSSREF := $(PANDOC_DIR)\pandoc-crossref.exe
SEVENZIP := $(PANDOC_DIR)\7za.exe

# -------- Версии (СОВМЕСТИМЫЕ) --------
PANDOC_VERSION := 3.8.3
CROSSREF_VERSION := 0.3.22b

# -------- Архивы --------
PANDOC_ZIP := pandoc.zip
CROSSREF_7Z := pandoc-crossref.7z

# -------- URL --------
PANDOC_URL := https://github.com/jgm/pandoc/releases/download/$(PANDOC_VERSION)/pandoc-$(PANDOC_VERSION)-windows-x86_64.zip
CROSSREF_URL := https://github.com/lierdakil/pandoc-crossref/releases/download/v$(CROSSREF_VERSION)/pandoc-crossref-Windows-X64.7z
SEVENZIP_URL := https://www.7-zip.org/a/7za920.zip

# -------- Metadata --------
YAML := $(MARKDOWN_DIR)\metadata.yaml
BIB := $(MARKDOWN_DIR)\references.bib
CSL_FILE := $(MARKDOWN_DIR)\gost-r-7-0-5-2008-numeric.csl

# -------- Исходники --------
SOURCES := \
	$(SECTIONS_DIR)\01-title.md \
	$(SECTIONS_DIR)\02-introduction.md \
	$(SECTIONS_DIR)\03-methodology.md \
	$(SECTIONS_DIR)\04-methods.md \
	$(SECTIONS_DIR)\05-results.md \
	$(SECTIONS_DIR)\06-conclusions.md \
	$(SECTIONS_DIR)\07-references.md \
	$(SECTIONS_DIR)\08-contacts.md

# -------- Цели --------
all: tools check build

# -------- Установка инструментов --------
tools:
	@echo Installing Pandoc tools...
	@powershell -Command " \
		if (-not (Test-Path '$(PANDOC_DIR)')) { New-Item -ItemType Directory -Path '$(PANDOC_DIR)' | Out-Null }; \
		if (-not (Test-Path '$(PANDOC)')) { \
			Write-Host 'Downloading Pandoc $(PANDOC_VERSION)...'; \
			Invoke-WebRequest '$(PANDOC_URL)' -OutFile '$(PANDOC_ZIP)'; \
			Expand-Archive '$(PANDOC_ZIP)' -DestinationPath '$(PANDOC_DIR)' -Force; \
			$$exe = Get-ChildItem '$(PANDOC_DIR)' -Recurse -Filter pandoc.exe | Select-Object -First 1; \
			if (-not $$exe) { throw 'pandoc.exe not found' }; \
			Copy-Item $$exe.FullName '$(PANDOC)' -Force; \
			Get-ChildItem '$(PANDOC_DIR)\pandoc-*' -Directory | Remove-Item -Recurse -Force; \
			Remove-Item '$(PANDOC_ZIP)' -Force \
		}; \
		if (-not (Test-Path '$(SEVENZIP)')) { \
			Write-Host 'Downloading 7za...'; \
			Invoke-WebRequest '$(SEVENZIP_URL)' -OutFile '7za.zip'; \
			Expand-Archive '7za.zip' -DestinationPath '$(PANDOC_DIR)' -Force; \
			Remove-Item '7za.zip' -Force \
		}; \
		if (-not (Test-Path '$(CROSSREF)')) { \
			Write-Host 'Downloading pandoc-crossref...'; \
			Invoke-WebRequest '$(CROSSREF_URL)' -OutFile '$(CROSSREF_7Z)'; \
			& '$(SEVENZIP)' x '$(CROSSREF_7Z)' -o'$(PANDOC_DIR)' -y | Out-Null; \
			Remove-Item '$(CROSSREF_7Z)' -Force \
		}; \
		if (-not (Test-Path '$(CSL_FILE)')) { \
			Write-Host 'Downloading CSL...'; \
			Invoke-WebRequest 'https://raw.githubusercontent.com/citation-style-language/styles/master/gost-r-7-0-5-2008-numeric.csl' -OutFile '$(CSL_FILE)' \
		}"
	@echo Pandoc tools ready.

# -------- Проверки --------
check:
	@echo Checking environment...
	@if not exist "$(PANDOC)" (echo ERROR: pandoc.exe not found & exit 1)
	@if not exist "$(CROSSREF)" (echo ERROR: pandoc-crossref.exe not found & exit 1)
	@if not exist "$(YAML)" (echo ERROR: metadata.yaml not found & exit 1)
	@if not exist "$(BIB)" (echo ERROR: references.bib not found & exit 1)
	@if not exist "$(CSL_FILE)" (echo ERROR: CSL file not found & exit 1)
	@if not exist "$(REFERENCE_DOC)" (echo ERROR: reference.docx not found & exit 1)
	@echo OK.

# -------- Сборка --------
build:
	@echo Building $(OUTPUT)...
	"$(PANDOC)" $(SOURCES) --metadata-file="$(YAML)" --filter="$(CROSSREF)" --citeproc --bibliography="$(BIB)" --csl="$(CSL_FILE)" --resource-path="$(MARKDOWN_DIR)" --reference-doc="$(REFERENCE_DOC)" -f markdown -t docx -s -o "$(OUTPUT)"
	@echo Done: $(OUTPUT)

# -------- Очистка --------
clean:
	@if exist "$(OUTPUT)" del "$(OUTPUT)"
