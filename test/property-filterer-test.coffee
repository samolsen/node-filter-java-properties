PropertyFilterer = require '../src/property-filterer'
Property = require '../src/property'
fs = require('fs')
path = require('path')
expect = require('chai').expect
ArgumentError = require('common-errors').ArgumentError

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

  describe 'filterStream', ()->
    inFilePath = path.resolve(__dirname, 'test-config.json')
    inStream = null
    beforeEach ()->
      inStream = fs.createReadStream(inFilePath)

    it 'should throw an error if an input stream is not provided', ()->
      fn = ()-> filterer.filterStream()
      expect(fn).to.throw(ArgumentError)

    it 'should return a string if an outStream is not provided', (done)->
      filterer.filterStream(
        inStream: inStream,
        done: (err, resultString)->
          expect(err).to.be.null
          expect(resultString).not.to.be.null
          done()
      )

    it 'should not return a string if an outStream is passed without the buildString option set', (done)->
      outStream = fs.createWriteStream('/tmp/property-filter-test')

      filterer.filterStream(
        inStream: inStream,
        outStream: outStream,
        done: (err, resultString)->
          expect(err).to.be.null
          expect(resultString).to.be.undefined
          done()
      )
    
    it 'should return a string if an outStream is passed with the buildString option set', (done)->
      outStream = fs.createWriteStream('/tmp/property-filter-test')

      filterer.filterStream(
        inStream: inStream,
        outStream: outStream,
        buildString: true,
        done: (err, resultString)->
          expect(err).to.be.null
          expect(resultString).not.to.be.undefined
          done()
      )

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
      
      it 'should throw an error if an input stream is not provided', ()->
        fn = ()-> PropertyFilterer.withStream()
        expect(fn).to.throw(ArgumentError)

      it 'should read the stream', (done)->   
        PropertyFilterer.withStream(
          inStream: inStream,
          done: (err, filterer)->
            expect(err).to.be.null
            expect(filterer).not.to.be.null
            expect(filterer.properties).to.have.length(12)
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
