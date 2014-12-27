_ = require('underscore')
Property = require('./property')

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

  new PropertyFilterer(properties: properties)

PropertyFilterer.getDefaultOptions = ()-> DEFAULT_OPTIONS

module.exports = PropertyFilterer