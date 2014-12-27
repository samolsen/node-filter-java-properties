PropertyFilterer = require '../src/property-filterer'
Property = require '../src/property'
expect = require('chai').expect

describe 'PropertyFilterer', ()->

  property = null
  filterer = null
  beforeEach ()->
    property = new Property('foo=bar')
    filterer = new PropertyFilterer(properties: [property]);
  
  describe 'constructor', ()->
    it 'should set the properties attr', ()->
      expect(filterer.properties).to.eql([property])

    it 'should use default delimiters if they are not passed', ()->
      defaultOptions = PropertyFilterer.getDefaultOptions()
      expect(filterer.delimiters).to.eql(defaultOptions.delimiters)

    it 'should override default delimiters if passed', ()->
      delimiters = '%*%'
      filterer = new PropertyFilterer(properties: [property], delimiters: delimiters)
      expect(filterer.delimiters).to.eql([delimiters])

  describe 'filterString', ()->
    it 'should filter multiple properties', ()->
      string = "hello @foo@\ngoodbye ${foo}"
      expect(filterer.filterString(string)).to.equal("hello bar\ngoodbye bar")

  describe 'static methods', ()->
    describe 'withString', ()->
      it 'should skip blank lines', ()->
        string = "foo=hello\n\n\nbar=world"
        filterer = PropertyFilterer.withString(string)
        expect(filterer.properties).to.have.length(2)
