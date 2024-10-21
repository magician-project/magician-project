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
```

## Building the documentation

The website version of the documentation is built with [sphinx](https://www.sphinx-doc.org/en/master/).

**Optional step**: initialise a python virtual environment:
```bash
python3 -m venv .venv
source .venv/bin/activate
```

Install the required python packages:
```bash
pip install -r requirements.txt
```

To build the documentation properly, there's a Makefile that can be used to build the documentation:
```bash
make
```

The entry point of the website can be found under `html/index.html`.
