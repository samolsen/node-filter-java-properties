_ = require('underscore')
Property = require('./property')
ArgumentError = require('common-errors').ArgumentError

DEFAULT_OPTIONS =
  # Delimiters matching Maven Resources plugin defaults,
  # see http://maven.apache.org/plugins/maven-resources-plugin/resources-mojo.html
  delimiters: ['${*}', '@'],
  
  # Close output streams by default, see `PropertyFilter#filterStream`
  # Set to false when writing to stdout or another stream which can't be closed
  closeOutStream: true

class PropertyFilter

  # Using a static factory function is preferred to direct instantiation
  #
  constructor: (options)->
    options ||= {}
    @properties = options.properties
    @delimiters = options.delimiters || DEFAULT_OPTIONS.delimiters 
    @delimiters = [@delimiters] unless _.isArray(@delimiters)

  # Pass a string through the filter for each of the receiver's Property objects
  #
  filterString: (string)->
    _.each @properties, (property)=>
      _.each @delimiters, (delimeter)=>
        string = property.filterString(string, delimeter)
    string

  # Filter an input stream. Writes to a string, a provided output stream, or both.
  # 
  filterStream: (options)->
    options = _.extend({}, DEFAULT_OPTIONS, options)
    throw new ArgumentError('An input stream is required') unless options && options.inStream
    
    # An input stream, required
    inStream = options.inStream
    
    # An optional output stream to write to
    outStream = options.outStream
   
    # An optional callback function with signature (error, resultString?) 
    # called when the input stream is finished
    done = options.done

    # Pass a string to the `done` callback even if an ouput stream is provided
    # A string is passed by default when an output stream is not provided
    buildString = options.buildString || !options.outStream
    
    # A flag indicating if this method should close the output stream
    closeOutStream = options.closeOutStream

    buffer = ''
    resultString = '' if buildString

    process = (line)=> 
      filteredLine = @filterString(line)
      resultString += filteredLine if buildString
      outStream && outStream.write(filteredLine)

    inStream.on 'data', (chunk)->
      buffer += chunk
      idx = buffer.indexOf("\n")
      while idx > -1
        idx++
        line = buffer.substring(0, idx)
        buffer = buffer.substring(idx)
        process(line)
        idx = buffer.indexOf("\n")
      true

    inStream.on 'end', ()->
      process(buffer) if buffer.length > 0
      outStream && closeOutStream && outStream.end()
      done && done(null, resultString)

    inStream.on 'error', (e)->
      outStream && closeOutStream && outStream.end()
      done && done(e)

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
#
PropertyFilter.withStream = (options)->
  throw new ArgumentError('An input stream is required') unless options && options.inStream
  
  # An input stream
  inStream = options.inStream

  # An optional callback function with signature (error, PropertyFilter?) called when the input stream is finished
  done = options.done

  properties = []
  buffer = ''
  process = (line)-> 
    if Property.isParseableString(line)
      properties.push(new Property(line, options))

  inStream.on 'data', (chunk)->
    buffer += chunk
    idx = buffer.indexOf("\n")
    while idx > -1
      idx++
      line = buffer.substring(0, idx)
      buffer = buffer.substring(idx)
      process(line)
      idx = buffer.indexOf("\n")
    true

  inStream.on 'end', ()->
    process(buffer) if buffer.length > 0
    options = _.extend({}, options, {properties: properties})
    done && done(null, new PropertyFilter(options))

  inStream.on 'error', (e)->
    done && done(e)


PropertyFilter.getDefaultOptions = ()-> DEFAULT_OPTIONS

module.exports = PropertyFilter
