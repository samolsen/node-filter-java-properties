PropertyFilter = require '../src/property-filter'
Property = require '../src/property'
fs = require('fs')
path = require('path')
expect = require('chai').expect
ArgumentError = require('common-errors').ArgumentError
through = require('through2')

describe 'PropertyFilter', ()->

  property = null
  filter = null
  beforeEach ()->
    property = new Property('foo=bar')
    filter = new PropertyFilter(properties: [property]);
  
  describe 'constructor', ()->
    it 'should set the properties attr', ()->
      expect(filter.properties).to.eql([property])

    it 'should use default delimiters if they are not passed', ()->
      defaultOptions = PropertyFilter.getDefaultOptions()
      expect(filter.delimiters).to.eql(defaultOptions.delimiters)

    it 'should override default delimiters if passed', ()->
      delimiters = '%*%'
      filter = new PropertyFilter(properties: [property], delimiters: delimiters)
      expect(filter.delimiters).to.eql([delimiters])

  describe 'filterString', ()->
    it 'should filter properties', ()->
      string = "hello @foo@\ngoodbye ${foo}"
      expect(filter.filterString(string)).to.equal("hello bar\ngoodbye bar")

  describe 'filterStream', ()->
    inStream = null
    beforeEach ()->
      inStream = through()
      inStream.end("hello @foo@\ngoodbye ${foo}")

    it 'should filter properties', (done)->
      out = ''
      filter.filterStream(inStream)
        .on 'data', (chunk)-> out += chunk
        .on 'end', ()->
          expect(out).to.equal("hello bar\ngoodbye bar")
          done()

  describe 'static methods', ()->
    describe 'withString', ()->
      propertiesString = "foo=hello\n\n\nbar=world"

      it 'should skip blank lines', ()->
        filter = PropertyFilter.withString(string: propertiesString)
        expect(filter.properties).to.have.length(2)

      it 'should accept a delimiters option', ()->
        delimiters = ['%']
        filter = PropertyFilter.withString(string: propertiesString, delimiters: delimiters)
        expect(filter.delimiters).to.eql(delimiters)

    describe 'withStream', ()->
      filePath = path.resolve(__dirname, 'test.properties')  

      inStream = null
      beforeEach ()->
        inStream = fs.createReadStream(filePath)
      
      it 'should throw an error if an input stream is not provided', ()->
        fn = ()-> PropertyFilter.withStream()
        expect(fn).to.throw(ArgumentError)

      it 'should read the stream', (done)->   
        PropertyFilter.withStream(
          inStream: inStream,
          done: (err, filter)->
            expect(err).to.be.null
            expect(filter).not.to.be.null
            expect(filter.properties).to.have.length(12)
            done()
        )

      it 'should accept a delimiters option', (done)->
        delimiters = ['%']

        PropertyFilter.withStream(
          inStream: inStream,
          delimiters: delimiters
          done: (err, filter)->
            expect(filter.delimiters).to.eql(delimiters)
            done()
        )        
