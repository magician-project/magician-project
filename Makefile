MD_FILES = $(shell find . -name '*.md')


# Python variables (for the virtual environment)
VENV = .venv
PYTHON = $(VENV)/bin/python3
PIP = $(VENV)/bin/pip
ACTIVATE = $(if $(wildcard $(VENV)/bin/activate), . $(VENV)/bin/activate, echo "Not using virtual environment")

.PHONY: docs clean view venv

docs: html

html: $(MD_FILES) plantuml.jar
	@echo "Building documentation"
	$(ACTIVATE) && sphinx-build --conf-dir docs . html

plantuml.jar:
	@echo "Downloading plantuml"
	@wget https://github.com/plantuml/plantuml/releases/download/v1.2024.8/plantuml-1.2024.8.jar -q -O plantuml.jar

view: docs
	@xdg-open html/index.html 2>>/dev/null& disown|| open html/index.html 2>>/dev/null

clean:
	@echo "Removing files"
	@rm html/ -r 2>>/dev/null || true


# Virtual environment
venv: $(VENV)/bin/activate requirements.txt

$(VENV)/bin/activate:
	@echo "Creating a new virtual environment..."
	@python3 -m venv $(VENV)
	@echo "Installing dependencies..."
	@$(PIP) install -r requirements.txt
	@touch $(VENV)/bin/activate
	@echo "Dependencies installed."
