_ = require('underscore')
expect = require('chai').expect
errors = require('common-errors')
ArgumentError = errors.ArgumentError
Property = require('../src/property')

describe 'Property', ()->

  property = null
  beforeEach ()->
    property = new Property('foo.bar=Hello World')
  
  describe 'constructor', ()->
    it 'should parse the key', ()->
      expect(property.key).to.equal('foo.bar')
      
    it 'should parse the value', ()->
      expect(property.value).to.equal('Hello World')
    
    it 'should trim the key', ()->
      property = new Property(' foo   =Hello World')
      expect(property.key).to.equal('foo')

    it 'should trim the value', ()->
      property = new Property('foo=  Hello World  ')
      expect(property.value).to.equal('Hello World')
    
    it 'should throw an error if it could not be split', ()->
      fn = ()-> new Property('abc')
      expect(fn).to.throw(ArgumentError)

  describe 'toRegExp', ()->
    it 'should throw an error if a string is not passed', ()->
      fn = ()-> property.toRegExp()
      expect(fn).to.throw(ArgumentError)

    it 'should throw an error if an empty string is passed', ()->
      fn = ()-> property.toRegExp('')
      expect(fn).to.throw(ArgumentError)

    it 'should throw an error if its arguments containts mulptiple "*" characters', ()->
      fn = ()-> property.toRegExp('${*|*}')
      expect(fn).to.throw(ArgumentError)

    describe 'arguments with a "*" token', ()->
      token = '${*}'
      regex = null
      beforeEach ()->
        regex = property.toRegExp(token)

      it 'should return a regex', ()->
        isRegex = _.isRegExp(regex)
        expect(isRegex).to.be.true

      it 'should return a regex matching bracketed tokens', ()->
        expect(regex.toString()).to.equal('/\\$\\{foo\\.bar\\}/g')

      it 'should return a regex with the global flag set', ()->
        expect(regex.toString()).to.match(/\/([imy]+)?g([imy]+)?$/)

    describe 'arguments without a "*" token', ()->
      token = '@'
      regex = null
      beforeEach ()->
        regex = property.toRegExp(token)

      it 'should return a regex', ()->
        isRegex = _.isRegExp(regex)
        expect(isRegex).to.be.true

      it 'should return a regex matching bracketed tokens', ()->
        expect(regex.toString()).to.equal('/'+ token + 'foo\\.bar' + token + '/' + 'g')

      it 'should return a regex with the global flag set', ()->
        expect(regex.toString()).to.match(/\/([imy]+)?g([imy]+)?$/)

  describe 'filterString with a "*" token', ()->
    token = '${*}'
    string = '${foo.bar}'

    it 'should replace the bracketed token', ()->
      filtered = property.filterString(string, token)
      expect(filtered).to.equal('Hello World')

  describe 'filterString with a "*" token', ()->
    token = '${*}'
    string = '${foo.bar}'

    it 'should replace the bracketed token', ()->
      filtered = property.filterString(string, token)
      expect(filtered).to.equal('Hello World')

  describe 'filterString without a "*" token', ()->
    token = '@'
    string = '@foo.bar@'

    it 'should replace the bracketed token', ()->
      filtered = property.filterString(string, token)
      expect(filtered).to.equal('Hello World')

  describe 'static methods', ()->
    describe 'isParseableString', ()->  
      it 'should return false if no "=" is present', ()->
        expect(Property.isParseableString('wge3g')).to.be.false
      
      it 'should return true if 1 "=" is present', ()->
        expect(Property.isParseableString('foo.bar=Booyah!')).to.be.true

      it 'should return true if more than 1 "=" is present', ()->
        expect(Property.isParseableString('foo.bar=Booyah = Grandma')).to.be.true
  
