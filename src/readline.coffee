through = require('through2')

# Function transforming an input stream to another stream, which emits 
# data as lines read from the input.
module.exports = ()->
  buffer = ''
  through.obj(
    # transform function
    (chunk, enc, cb)->
      buffer += chunk
      idx = buffer.indexOf("\n")
      while idx > -1
        idx++
        line = buffer.substring(0, idx)
        buffer = buffer.substring(idx)
        idx = buffer.indexOf("\n")

        this.push(line)
      cb()
    
    # flush function
    (cb)->
      this.push(buffer)
      cb()
  )