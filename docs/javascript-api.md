## Javascript API

The JS API consists of a `PropertyFilter` class, which takes a **.properties** file, and filters strings or input streams. See the [PropertyFilter source](../src/property-filter.coffee). 

```js
var PropertyFilter = require('filter-java-properties').PropertyFilter;
```

Calling `new PropertyFilter()` isn't recommended. Instead, use the `PropertyFilter.withString()` or `PropertyFilter.withStream()` convenience functions.

#### Creating a filter with properties as a string

When the contents of a **.properties** file is a string, use `PropertyFilter.withString()`.

```js
var propertiesString = fs.readFileSync('/tmp/configure.properties').toString();
var filter = PropertyFilter.withString({string: propertiesString});
```

#### Creating a filter with properties from an input stream

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

#### Filter delimiters

`PropertyFilter` instances use the Maven Resources filtering delimiter defaults of `${*}` and `@`. These delimiters may be overriden by passing a `delimiters:` option to `PropertyFilter.withString()` or `PropertyFilter.withStream()`.

```js
PropertyFilter.withString({string: string, delimiters: '%'})

PropertyFilter.withStream({inStream: inputStream, delimiters: ['%', '${*}', '(*)']});
```


#### Using a filter

As with creating the `PropertyFilter` instance, filtering works on strings and streams.

```js
var string = STRING;
var filteredString = filter.filterString(string);
```

```js
var inputStream, outStream;

filter.filterStream(inputStream).pipe(outStream);
```
