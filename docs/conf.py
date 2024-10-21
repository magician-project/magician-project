project = "Magician"
copyright = "The Magician Consortium"
# author = ""
# release = ""

extensions = [
    "sphinx.ext.napoleon",
    "sphinxcontrib.mermaid", 
    "myst_parser",
]

pygments_style = 'sphinx'

html_theme = 'furo'
autosummary_generate = True
myst_enable_extensions = ["deflist"]
