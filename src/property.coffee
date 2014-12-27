_ = require('underscore')
ArgumentError = require('common-errors').ArgumentError

# Escape a string for literal match in a regular expression 
#
# See https://developer.mozilla.org/en/docs/Web/JavaScript/Guide/Regular_Expressions
escapeRegExp = (string)-> string.replace(/[.*+?^${}()|[\]\\]/g, "\\$&");


### Property ###
class Property
  constructor: (string)->
    throw new ArgumentError('property string could not be split on an "=" token') unless Property.isParseableString(string)
    split = string.split('=')
    @string = string
    @key = split.shift().trim()
    @value = split.join('').trim()
    
  # Create a regular expression for matching `this.key` values surrounded by `delimiter`
  toRegExp: (delimiter) ->
    throw new ArgumentError('invalid string passed to toRegExp()') unless delimiter && _.isString(delimiter)

    splitToken = delimiter.split('*')
  
    # If a delimiter is passed with multiple '\*' characters, the behavior becomes ambiguous.
    # Bail with an error.
    if splitToken.length > 2
      throw new ArgumentError('property string could not be split on a single "*" delimiter') 
  
    # If the delimiter can't split on a '\*', then bracket the key with the delimiter.
    # e.g.  '@' -> @key@ 
    else if splitToken.length == 1
      splitToken = [splitToken[0], splitToken[0]]

    new RegExp(escapeRegExp(splitToken[0]) + escapeRegExp(@key) + escapeRegExp(splitToken[1]), 'g')


  # String replacement using `this.key` and `this.value` with a delimiter.
  filterString: (string, delimiter)->
    regex = @toRegExp(delimiter)
    string.replace(regex, @value)

# Determine if a string can be parsed and used as a property.     
Property.isParseableString = (string)-> (string.match(/\=/g) || []).length >= 1

module.exports = Property
