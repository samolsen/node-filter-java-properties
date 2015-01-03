[![NPM version][npm-image]][npm-url] [![Build Status][travis-image]][travis-url]

A Node package for filtering text with key-value pairs parsed from Java .properties style configurations, intended to replicate the filtering behavior of the [Maven Resources plugin](http://maven.apache.org/plugins/maven-resources-plugin/resources-mojo.html).


## Installation

Install the package with:

```
npm install filter-java-properties
```

## Use

The package contains a Javascript API and CLI for filtering strings/input streams.

[Use in Javascript](docs/javascript-api.md)

[Use from the command line](docs/cli.md)

## Plugins

[Gulp](http://gulpjs.com/) and [Grunt](http://gruntjs.com/) wrappers are available for this package:

[Gulp plugin](https://github.com/samolsen/gulp-filter-java-properties)

[Grunt plugin](https://github.com/samolsen/grunt-filter-java-properties)


## License

[MIT License](http://en.wikipedia.org/wiki/MIT_License)

[npm-url]: https://npmjs.org/package/filter-java-properties
[npm-image]: https://badge.fury.io/js/filter-java-properties.png

[travis-url]: http://travis-ci.org/samolsen/node-filter-java-properties
[travis-image]: https://secure.travis-ci.org/samolsen/node-filter-java-properties.png?branch=master