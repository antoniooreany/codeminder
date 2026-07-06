name: Python CI

on:
  push:
    branches:
      - main
      - develop
      - feature/**
  pull_request:
    branches:
      - main
      - develop

jobs:
  test:
    runs-on: ubuntu-latest

    steps:
      - name: Checkout repository
        uses: actions/checkout@v4

      - name: Set up Python
        uses: actions/setup-python@v5
        with:
          python-version: "3.12"

      - name: Show Python version
        run: python --version

      - name: Run CLI doctor
        run: python src/cli/main.py doctor

      - name: Run hooks doctor
        run: python src/cli/main.py hooks doctor