PropertyFilterer = require '../src/property-filterer'
Property = require '../src/property'
fs = require('fs')
path = require('path')
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
      propertiesString = "foo=hello\n\n\nbar=world"

      it 'should skip blank lines', ()->
        filterer = PropertyFilterer.withString(propertiesString)
        expect(filterer.properties).to.have.length(2)

      it 'should accept a delimiters option', ()->
        delimiters = ['%']
        filterer = PropertyFilterer.withString(propertiesString, {delimiters: delimiters})
        expect(filterer.delimiters).to.eql(delimiters)

    describe 'withStream', ()->
      filePath = path.resolve(__dirname, 'test.properties')  

      inStream = null
      beforeEach ()->
        inStream = fs.createReadStream(filePath)
      
      it 'should read the stream', (done)->   
        PropertyFilterer.withStream(
          inStream: inStream,
          done: (err, filterer)->
            expect(err).to.be.null
            expect(filterer).not.to.be.null
            expect(filterer.properties).to.have.length(6)
            done()
        )

      it 'should accept a delimiters option', (done)->
        delimiters = ['%']

        PropertyFilterer.withStream(
          inStream: inStream,
          delimiters: delimiters
          done: (err, filterer)->
            expect(filterer.delimiters).to.eql(delimiters)
            done()
        )        
