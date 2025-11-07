# Contributing to nanodRop

Thank you for your interest in contributing to nanodRop! We welcome
contributions from the community to help improve this R package for
analyzing NanoDrop spectrophotometer data.

## How to Contribute

There are several ways to contribute:

- Report bugs
- Suggest features
- Submit pull requests
- Improve documentation

Please read through this guide before contributing.

## Bug Reports

If you find a bug, please create an issue on GitHub with the following
information:

- A clear, descriptive title
- Steps to reproduce the bug
- Expected behavior
- Actual behavior
- Your R version and package versions (use
  [`sessionInfo()`](https://rdrr.io/r/utils/sessionInfo.html))
- Any relevant error messages or screenshots

## Feature Requests

We’d love to hear your ideas! Please open an issue on GitHub with:

- A clear description of the proposed feature
- Why you think it would be useful
- Any relevant examples or mockups

## Pull Requests

To submit a pull request:

1.  Fork the repository
2.  Create a feature branch from `main`
3.  Make your changes
4.  Add tests if applicable
5.  Update documentation
6.  Ensure all tests pass
7.  Submit a pull request with a clear description

Please follow the existing code style and conventions.

## Development Setup

To set up a development environment:

1.  Install R (version 4.0 or later recommended)

2.  Install required packages:

    ``` r
    install.packages(c("devtools", "roxygen2", "testthat", "pkgdown"))
    ```

3.  Clone the repository:

    ``` bash
    git clone https://github.com/yourusername/nanodRop.git
    ```

4.  Load the package in development mode:

    ``` r
    devtools::load_all()
    ```

5.  Run tests:

    ``` r
    devtools::test()
    ```

## Code Style

- Use tidyverse style guide
- Comment your code
- Write tests for new functionality
- Update NEWS.md for changes

## Questions?

If you have questions about contributing, please open an issue or
contact the maintainers.

Thank you for your contributions!
