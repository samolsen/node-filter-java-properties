_ = require('underscore')
ArgumentError = require('common-errors').ArgumentError

escapeRegExp = (string)-> string.replace(/[.*+?^${}()|[\]\\]/g, "\\$&");

class Property
  constructor: (string)->
    throw new ArgumentError('property string could not be split on an "=" token') unless Property.isParseableString(string)
    
    split = string.split('=')
    @string = string
    @key = split.shift().trim()
    @value = split.join('').trim()
    
  toRegExp: (token) ->
    throw new ArgumentError('invalid string passed to toRegExp()') unless token && _.isString(token)

    splitToken = token.split('*')
  
    if splitToken.length > 2
      throw new ArgumentError('property string could not be split on an "=" token') 
  
    else if splitToken.length == 1
      splitToken = [splitToken[0], splitToken[0]]

    new RegExp(escapeRegExp(splitToken[0]) + '.*' + escapeRegExp(splitToken[1]), 'g')

  filterString: (string, token)->
    regex = @toRegExp(token)
    string.replace(regex, @value)
    
Property.isParseableString = (string)-> (string.match(/\=/g) || []).length >= 1

    
module.exports = Property
