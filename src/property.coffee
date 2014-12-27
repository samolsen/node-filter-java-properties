_ = require('underscore')
ArgumentError = require('common-errors').ArgumentError

escapeRegExp = (string)-> string.replace(/[.*+?^${}()|[\]\\]/g, "\\$&");

class Property
  constructor: (string)->
    split = string.split('=')
    
    throw new ArgumentError('property string could not be split on an "=" token') if split.length < 2

    @key = split.shift().trim()
    @value = split.join('').trim()
    
  toRegExp: (token) ->
    throw new ArgumentError('invalid string passed to toRegExp()') unless token && _.isString(token)

    splitToken = token.split('*')
  
    if splitToken.length > 2
      throw new ArgumentError('property string could not be split on an "=" token') 
  
    else if splitToken.length == 1
      splitToken = [splitToken[0], splitToken[0]]

    return new RegExp(escapeRegExp(splitToken[0]) + '.*' + escapeRegExp(splitToken[1]), 'g')
    
    
module.exports = Property
