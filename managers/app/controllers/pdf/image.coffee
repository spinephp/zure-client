###
PDFImage - embeds images in PDF documents
By Devon Govett
###

Data = require './data'
JPEG = require './image/jpeg'
PNG = require './image/png'

class PDFImage
    @open: (filenameOrBuffer) ->
        if typeof filenameOrBuffer is 'object' and filenameOrBuffer instanceof Buffer
            @contents = filenameOrBuffer
        else
            reader = new FileReader()
            @contents = reader.readAsArrayBuffer filenameOrBuffer
            return unless @contents
            
        @data = new Data @contents
        @filter = null
        
        # load info
        data = @data
        firstByte = data.byteAt(0)
        
        if firstByte is 0xFF and data.byteAt(1) is 0xD8
            return new JPEG(data)
            
        else if firstByte is 0x89 and data.stringAt(1, 3) is "PNG"
            return new PNG(data)
            
        else
            throw new Error 'Unknown image format.'
                    
module.exports = PDFImage