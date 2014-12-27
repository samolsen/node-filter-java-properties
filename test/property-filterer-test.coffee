PropertyFilterer = require '../src/property-filterer'
expect = require('chai').expect

describe 'PropertyFilterer', ()->
  
  describe 'static methods', ()->
    describe 'withString', ()->
      it 'should skip blank lines', ()->
        string = "foo=hello\n\n\nbar=world"
        filterer = PropertyFilterer.withString(string)
        expect(filterer.properties).to.have.length(2)
