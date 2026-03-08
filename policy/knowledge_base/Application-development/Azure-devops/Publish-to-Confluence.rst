Publish to Confluence
=====================

To publish documentation to confluence you need a service account, to request this service account contact DevSupport (developmentsupport@apg.nl).

To publish documentation to Confluence, use the following tasks as a guide. To use the following example make sure to use RST format. For more information on Sphix visit the `Sphinx documentation <https://www.sphinx-doc.org/en/master/>`__ .

.. code-block:: yaml

    - task: Bash@3
      displayName: 'Install internal trusted root certificate chain'
      inputs:
        targetType: 'inline'
        script: |
          sudo curl -L -o /usr/local/share/ca-certificates/CA01-APG.crt http://prime03.office01.internalcorp.net/crt/CA01-APG.crt
          sudo curl -L -o /usr/local/share/ca-certificates/CA02-Azure.crt http://prime03.office01.internalcorp.net/crt/CA02-Azure.crt
          sudo curl -L -o /usr/local/share/ca-certificates/CA02-DC.crt http://prime03.office01.internalcorp.net/crt/CA02-DC.crt
          sudo curl -L -o /usr/local/share/ca-certificates/CA02-IRIS.crt http://prime03.office01.internalcorp.net/crt/CA02-IRIS.crt
          sudo update-ca-certificates
          cat /usr/local/share/ca-certificates/CA0*.crt >> apg-ca-bundle.crt

    - task: UsePythonVersion@0
      displayName: 'Use python 3.13'
      inputs:
        versionSpec: '3.13'
        architecture: 'x64'

    - task: Bash@3
      displayName: 'Install requirements'
      inputs:
        failOnStderr: false
        targetType: 'inline'
        script: |
          pip install sphinx # Best practice is to use JFrog Artifactory
          pip install sphinxcontrib-confluencebuilder # Best practice is to use JFrog Artifactory

    - task: Bash@3
      displayName: 'Publish to Confluence '
      name: 'PublishConfluence'
      env:
        CONFLUENCESECRET: $(confluenceSecret)  # Service Account of confluence
      inputs:
        targetType: 'inline'
        script: |
          # -b       BUILDER
          # -c       path of conf.py
          # -E       don't use a saved environment, always read all files
          # -a       write all files (default: only write new and changed files)
          # -j auto  if possible, parallelize the process
          sphinx-build -b confluence -c source/knowledge_base source/knowledge_base build/confluence/knowledge_base/ -E -a -j auto -D confluence_publish=True -D confluence_cleanup_purge=True -D confluence_space_key=$SPACEKEY

Use the following conf.py example and store the file in your project folder. Make sure to store the RST files you want to publish in the same folder as the conf.py:

.. code-block:: python

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

    # -- Project information -----------------------------------------------------

    project = '<PROJECT>'
    copyright = '<COPYRIGHT>'
    author = '<AUTHOR>'

    # The full version, including alpha/beta/rc tags
    release = '<RELEASE>'

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
    confluence_space_key = <CONFLUENCESPACEKEY>
    confluence_server_url = <CONFLUENCEURL>
    confluence_server_user = <CONFLUENCEUSER>
    confluence_server_pass = <CONFLUENCESECRET>

    # specific options for this folder
    confluence_publish = False
    confluence_purge = False
    confluence_page_hierarchy = True
    confluence_root_homepage = True
