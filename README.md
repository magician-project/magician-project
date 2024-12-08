# Magician Documentation

This repository contains the practical documentation of the Magician project, with all technical details and guidelines to coordinate the different partners of the consortium.

The documentation can be accessed directly from the [GitHub repository](https://github.com/magician-project/), or from the [website](https://magician-project.github.io/magician-project/). 

All partners are encouraged to contribute in this repository, by making sure that the APIs of the components are properly updated.
To avoid conflicts, we recommend everyone to work on their own branch, and submit a pull request to main branch when changes are ready.
People from the University of Trento will make sure that all contents are properly merged in the stable branch.

## Note
At the current stage, the **repository** is **public**, so that we can use GitHub pages to host the website version of the documentation. 
So please, **do not share here sensitive information**.

In the upcoming months we can plan on making this documentation private by finding other solutions.


## Contents

```{toctree}
:maxdepth: 1

code_of_conduct.md
framework.md
materials.md
```

## Building the documentation

The website version of the documentation is built with [sphinx](https://www.sphinx-doc.org/en/master/).
To create the html version of the documentation:

1. Install the system dependencies. Dependencies are:
   - `wget`: to fetch external pre-compiled libraries;
   - a Java runtime environment to run external tools;
   - `graphviz`, to draw the UML diagrams;
   - `python3` and `pip` to install the required python packages.
   On Ubuntu-based systems, dependencies can be installed with:
   ``` bash
   sudo apt-get update && sudo apt-get install -y wget default-jre graphviz python3 python3-pip
   ```
1. install the required python packages:
   ```bash
   pip install -r requirements.txt
   ```
1. use the provided `Makefile` to build the documentation:
   ```bash
   make
   ```

During the call to make, the [plantuml](https://plantuml.com/download) binary is downloaded from the official website; this is a required tool to render the UML diagrams.
 
The entry point of the website can be found under `html/index.html`.

### Make targets

- `make docs`: default target; build the website version of the documentation at `html/`;
- `make html`: same as `make docs`;
- `make pdf`: creates the PDF version of the documentation (experimental support).
   To work, LaTeX must be installed on the local device. 
   Other dependencies could be required to properly build the PDF documentation, but are not yet listed due to lack of thorough testing;
- `make clean`: remove the built files;
- `make view`: uses the default browser to open the built documentation;
- `make venv`: creates a python virtual environment and installs all the required packages. 
   If the virtual environment is present, it is always used to build the documentation.
