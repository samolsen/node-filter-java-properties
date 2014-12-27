_ = require('underscore')
Property = require('./property')

OPTIONS_DEFAULTS =
  delimeters: ['${*}', '@']

class PropertyFilterer
  constructor: (properties, options)->
    options ||= {}
    @properties = properties
    @delimeters = _.extend({}, OPTIONS_DEFAULTS, options.delimeters)


  filterString: (string)->
    _.each @properties, (property)->
      _.each @delimeters, (delimeter)->
        string = property.filterString(string, delimeter)
    string

PropertyFilterer.withString = (string, options)->
  properties = _.chain(string.split("\n"))
    .map (line)-> new Property(line, options) if Property.isParseableString(line)
    .filter (property)-> property # reject undefined items
    .value()

  new PropertyFilterer(properties)

module.exports = PropertyFilterer