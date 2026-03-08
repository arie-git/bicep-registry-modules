# Configuration file for the Sphinx documentation builder.
#
# This file only contains a selection of the most common options. For a full
# list see the documentation:
# https://www.sphinx-doc.org/en/master/usage/configuration.html

# -- Path setup --------------------------------------------------------------

# If extensions (or modules to document with autodoc) are in another directory,
# add these directories to sys.path here. If the directory is relative to the
# documentation root, use os.path.abspath to make it absolute, like shown here.
#
import os
# import sys
# sys.path.insert(0, os.path.abspath('.'))

# -- Project information -----------------------------------------------------

project = 'knowledge_base'
copyright = '2023-2024, Ignite'
author = 'Ignite'

# The full version, including alpha/beta/rc tags
release = 'DRCP_24-4-02'

# -- General configuration ---------------------------------------------------

# Add any Sphinx extension module names here, as strings. They can be
# extensions coming with Sphinx (named 'sphinx.ext.*') or your custom
# ones.
extensions = [
    'sphinx.ext.todo',
    'sphinx.ext.coverage',
    'sphinx.ext.imgmath',
    'sphinx.ext.ifconfig',
    'sphinxcontrib.confluencebuilder'
]

# Add any paths that contain templates here, relative to this directory.
templates_path = ['_templates']

# List of patterns, relative to source directory, that match files and
# directories to ignore when looking for source files.
# This pattern also affects html_static_path and html_extra_path.
exclude_patterns = []

# Specify homepage as index.rst
master_doc = 'index'

# Linkcheck - Specify hyperlink paths to ignore.
linkcheck_ignore = [
    r'https://iam/.*',
    r'https://iam.office01.internalcorp.net/.*',
    r'https://portal.azure.com/.*',
    r'https://dev.azure.com/.*',
    r'https://techcommunity.microsoft.com/blog',
    r'https://{{.*'
]

# Linkcheck - Specify number of retries before reporting hyperlink as broken. Default is 1.
linkcheck_retries = 3

# Linkcheck - Specify number of parallel worker threads to use. Default is 5.
linkcheck_workers = 10

# -- Options for HTML output -------------------------------------------------

# The theme to use for HTML and HTML Help pages.  See the documentation for
# a list of builtin themes.
#
html_theme = 'alabaster'

# Add any paths that contain custom static files (such as style sheets) here,
# relative to this directory. They are copied after the builtin static files,
# so a file named "default.css" will overwrite the builtin "default.css".
html_static_path = ['_static']

# -- Options for output to Confluence ----------------------------------------
# Use this section for upload to Confluence.
# Install module using `pip install sphinxcontrib-confluencebuilder`

confluence_ca_cert = '/etc/ssl/certs'
confluence_space_key = os.environ["CONFLUENCESPACEKEY"]
confluence_server_url = os.environ["CONFLUENCEURL"]
confluence_server_user = os.environ["CONFLUENCEUSER"]
confluence_server_pass = os.environ["CONFLUENCESECRET"]

# specific options for this folder
confluence_publish = False
confluence_purge = False
confluence_page_hierarchy = True
confluence_root_homepage = True
