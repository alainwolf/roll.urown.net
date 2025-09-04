# roll.urown.net

How to roll your own private self-hosted internet services.

A guide thats helps me (and you) setting up contemporary digital devices in a
way that independence and privacy are maintened.

<https://roll.urown.net/>

Written in reStructuredText.

Built with [Sphinx](http://www.sphinx-doc.org/en/master/) using [a theme](https://github.com/rtfd/sphinx_rtd_theme)
provided by [Read the Docs](https://readthedocs.org/).

## To roll your own

### Clone

```bash
git clone https://github.com/alainwolf/roll.urown.net.git
cd roll.urown.net
```

### Install

Install the Sphinx Python packages into a virtual environment.

```bash
python3 -m venv .venv
source .venv/bin/activate
pip install -r requirements.txt
```

### Roll

```bash
make
```

### Update

```bash
pip install --upgrade pip
source .venv/bin/activate
pip install --upgrade -r requirements.txt
```


© Copyright 2014, 2025, roll.urown.net - Creative Commons Attribution-ShareAlike 4.0 International License.
