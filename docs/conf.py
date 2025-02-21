import os.path

project = "Magician"
copyright = "The Magician Consortium"
# author = ""
# release = ""

extensions = [
    "sphinx.ext.napoleon",
    "sphinxcontrib.mermaid", 
    "sphinxcontrib.plantuml", 
    "myst_parser",
]

pygments_style = 'sphinx'

this_file_path = os.path.abspath(os.path.dirname(__file__))
this_file_dir = os.path.dirname(this_file_path)
root_path = os.path.normpath(os.path.join(this_file_path, ".."))
plantuml_output_format = "svg"
plantuml = f'java -jar {root_path}/plantuml.jar'
plantuml_latex_output_format = 'pdf'

html_theme = 'furo'
autosummary_generate = True
myst_enable_extensions = ["deflist"]
