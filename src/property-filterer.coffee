_ = require('underscore')
Property = require('./property')
ArgumentError = require('common-errors').ArgumentError

DEFAULT_OPTIONS =
  # Some default delimiters, matching Maven Resources plugin defaults
  # see http://maven.apache.org/plugins/maven-resources-plugin/resources-mojo.html
  delimiters: ['${*}', '@'],
  
  # Close output streams by default, see filterStream()
  # Set to false when writing to stdout or another stream which can't be closed
  closeOutStream: true

class PropertyFilterer

  # Using a static factory function is preferred to direct instantiation
  # 
  # Pointless without passing a properties list containing at least one Property.
  # If delimiters are not passed, then DEFAULT_OPTIONS.delimiters are used
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

  # Filter an input stream. Writes to a string, a provided output stream, or both.
  # 
  # options: 
  # inStream        (required) an input stream
  # outStream       (optional) an output stream to write to
  # done            (optional) a callback function with signature (error, resultString?) called when the input stream is finished
  # closeOutStream  (optional)flag indicating if this method should close the output stream
  filterStream: (options)->
    options = _.extend({}, DEFAULT_OPTIONS, options)
    throw new ArgumentError('An input stream is required') unless options && options.inStream
    
    inStream = options.inStream
    outStream = options.outStream
    done = options.done
    buildString = options.buildString || !options.outStream
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

# Create a PropertyFilterer using a string containing .properties file contents
#
# options:
# string  (required) the string to parse the Property list from
#
# options may also include any attributes which are used by the PropertyFilterer constructor
PropertyFilterer.withString = (options)->
  properties = _.chain(options.string.split("\n"))
    .map (line)-> new Property(line, options) if Property.isParseableString(line)
    .filter (property)-> property # reject undefined items
    .value()

  options = _.extend({}, options, {properties: properties})
  new PropertyFilterer(options)

# Create a PropertyFilterer, parsing an input stream for the Property list
#
# options:
# inStream  (required) an input stream 
# done      (optional) a callback function with signature (error, PropertyFilterer?) called when the input stream is finished
PropertyFilterer.withStream = (options)->
  throw new ArgumentError('An input stream is required') unless options && options.inStream
  
  inStream = options.inStream
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
    done && done(null, new PropertyFilterer(options))

  inStream.on 'error', (e)->
    done && done(e)


PropertyFilterer.getDefaultOptions = ()-> DEFAULT_OPTIONS

module.exports = PropertyFilterer
