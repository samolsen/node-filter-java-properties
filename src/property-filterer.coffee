_ = require('underscore')
Property = require('./property')
ArgumentError = require('common-errors').ArgumentError


DEFAULT_OPTIONS =
  delimiters: ['${*}', '@']

class PropertyFilterer
  constructor: (options)->
    options ||= {}
    @properties = options.properties
    @delimiters = options.delimiters || DEFAULT_OPTIONS.delimiters 
    @delimiters = [@delimiters] unless _.isArray(@delimiters)

  filterString: (string)->
    _.each @properties, (property)=>
      _.each @delimiters, (delimeter)=>
        string = property.filterString(string, delimeter)
    string

PropertyFilterer.withString = (string, options)->
  properties = _.chain(string.split("\n"))
    .map (line)-> new Property(line, options) if Property.isParseableString(line)
    .filter (property)-> property # reject undefined items
    .value()

  options = _.extend({}, options, {properties: properties})
  new PropertyFilterer(options)

PropertyFilterer.withStream = (options)->
  throw new ArgumentError('An input stream is required') unless options.inStream
  
  inStream = options.inStream
  done = options.done

  properties = []
  buffer = ''
  process = (line)-> 
    if Property.isParseableString(line)
      properties.push(new Property(line, options))

  inStream.on 'data', (chunk)->
    buffer += chunk.toString()
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