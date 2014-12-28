A Node package for filtering text with key-value pairs parsed from Java .properties style configurations, intended to replicate the filtering behavior of the [Maven Resources plugin](http://maven.apache.org/plugins/maven-resources-plugin/resources-mojo.html).

The package contains a Javascript API and CLI for filtering strings/input streams. 

## Javascript API

The JS API consists of a `PropertyFilter` class, which takes a **.properties** file, and filters strings or input streams. See the [PropertyFilter docs](docs/property-filter.html) for greater detail. 

#### Creating a `PropertyFilter` with properties as a string

When the contents of a **.properties** file is a string, use `PropertyFilter.withString()`.

```js
var propertiesString = fs.readFileSync('/tmp/configure.properties').toString();
var filter = PropertyFilter.withString({string: propertiesString});
```

#### Creating a `PropertyFilter` with properties from an input stream

When the contents of a **.properties** file is from an input stream, use `PropertyFilter.withStream()`.

```js
var inputStream = fs.createReadStream('/tmp/configure.properties');

PropertyFilter.withStream({
  inStream: inputStream,
  done: function(err, filter) {
    // use the filter
  }
});
```

### `PropertyFilter` delimiters

`PropertyFilter` instances use the Maven Resources filtering delimiter defaults of `${*}` and `@`. These delimiters may be overriden by passing a `delimiters:` option to `PropertyFilter.withString()` or `PropertyFilter.withStream()`.

```js
PropertyFilter.withString({string: string, delimiters: '%'})

PropertyFilter.withStream({inStream: inputStream, delimiters: ['%', '${*}', '(*)']});
```


#### Using a **PropertyFilter**

As with creating the `PropertyFilter`, filtering works on strings and streams.

```js
var string = STRING;
var filteredString = filter.filterString(string);
```

```js
var inputStream = READABLE_STREAM;
var outStream = WRITEABLE_STREAM;

filter.filterStream({
  inStream: inputStream, // required, Stream of text to filter
  outStream: outStream, // optional, Stream to write to 
  done: function(err, filteredString) { // optional
    // Called when reading the input stream has finished
  },
  buildString: false, // optional, Builds filteredString passed to `done` when true. 
                      // By default, if `outStream` is provided the filtered string will not be 
                      // built. If `outStream` is not provided, the filteredString is always
                      // built and passed to the callback
  closeOutStream: true // optional. Flag indicating this method should try to close the `outStream`
                       // true by default
})
```


## CLI

A simple CLI for filtering files is provided in `bin/filter-java-properties`.

The basic syntax: 

```sh
filter-java-properties $PROPERTIES_FILE $FILTER_SOURCE
```

Without passing options, the source is filtered with the default delimiters and sent to `stdout`.

Supported options:

`--outpath` or `-o` file path where the filtered file should be written

`--delimiter` or `-d` delimiter to use for filtering. This option may be used multiple times.

`--encoding` encoding for the output file, default `'utf8'`


