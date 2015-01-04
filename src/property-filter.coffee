_ = require('underscore')
Property = require('./property')
ArgumentError = require('common-errors').ArgumentError
through = require('through2')

### Defaults ###

DEFAULT_OPTIONS =
  # Delimiters matching Maven Resources plugin defaults,
  # see http://maven.apache.org/plugins/maven-resources-plugin/resources-mojo.html
  delimiters: ['${*}', '@'],

# Function transforming an input stream to another stream, which emits 
# data as lines read from the input.
readLine = ()->
  buffer = ''
  through.obj(
    # transform function
    (chunk, enc, cb)->
      buffer += chunk
      idx = buffer.indexOf("\n")
      while idx > -1
        idx++
        line = buffer.substring(0, idx)
        buffer = buffer.substring(idx)
        idx = buffer.indexOf("\n")

        this.push(line)
      cb()
    
    # flush function
    (cb)->
      this.push(buffer)
      cb()
  )

## Property Filter ##

class PropertyFilter

  # Using a static factory function is preferred to direct instantiation
  constructor: (options)->
    options ||= {}
    @properties = options.properties
    @delimiters = options.delimiters || DEFAULT_OPTIONS.delimiters 
    @delimiters = [@delimiters] unless _.isArray(@delimiters)

  # Pass a string through the filter for each of the receiver's Property objects
  filterString: (string)->
    _.each @properties, (property)=>
      _.each @delimiters, (delimeter)=>
        string = property.filterString(string, delimeter)
    string

  # Filter an input stream, returning an output stream with the filtered content
  filterStream: (inStream)->
    filter = this
    filterTransform = through.obj (line, enc, cb)->
      this.push filter.filterString(line)
      cb()

    inStream
      .pipe(readLine())
      .pipe(filterTransform)

### Static Methods / Factories ###

# Create a PropertyFilter using a string containing .properties file contents
#
# `options` may include any attributes which are used by the PropertyFilter constructor
PropertyFilter.withString = (options)->
  # The string to parse the Property list from
  string = options.string

  properties = _.chain(options.string.split("\n"))
    .map (line)-> new Property(line, options) if Property.isParseableString(line)
    .filter (property)-> property # reject undefined items
    .value()

  options = _.extend({}, options, {properties: properties})
  new PropertyFilter(options)

# Create a PropertyFilter, parsing an input stream for the Property list
PropertyFilter.withStream = (options)->
  throw new ArgumentError('An input stream is required') unless options && options.inStream
  
  # `options.inStream` __*required*__ -
  # An input stream used to parse properties
  inStream = options.inStream

  # `options.done` *optional* -
  # Callback function with signature `function(error, PropertyFilter?)` called when the input 
  # stream is finished
  done = options.done

  # Parsed properties list
  properties = []

  inStream.pipe(readLine())
    
    .on 'data', (line)-> 
      if Property.isParseableString(line)
        properties.push(new Property(line, options))

    .on 'end', ()->
      options = _.extend({}, options, {properties: properties})
      done && done(null, new PropertyFilter(options))

    .on 'error', (e)-> 
      done && done(e)

# Get a copy of the `DEFAULT_OPTIONS` object
PropertyFilter.getDefaultOptions = ()-> _.clone(DEFAULT_OPTIONS)

module.exports = PropertyFilter
