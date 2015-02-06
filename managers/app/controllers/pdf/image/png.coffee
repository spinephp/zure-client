#zlib = require 'zlib'
PNG = require 'png-js'

class PNGImage
    constructor: (data) ->
        @image = new PNG(data.data)
        @width = @image.width
        @height = @image.height
        @imgData = @image.imgData
        
    object: (document, fn) ->
        # get the async stuff out of the way first
        if not @alphaChannel
            if @image.transparency.indexed
                # Create a transparency SMask for the image based on the data 
                # in the PLTE and tRNS sections. See below for details on SMasks.
                @loadIndexedAlphaChannel => @object document, fn
                return
            
            else if @image.hasAlphaChannel
                # For PNG color types 4 and 6, the transparency data is stored as a alpha
                # channel mixed in with the main image data. Separate this data out into an
                # SMask object and store it separately in the PDF.
                @splitAlphaChannel => @object document, fn
                return
                
        obj = document.ref
            Type: 'XObject'
            Subtype: 'Image'
            BitsPerComponent: @image.bits
            Width: @width
            Height: @height
            Length: @imgData.length
            Filter: 'FlateDecode'

        unless @image.hasAlphaChannel
            obj.data['DecodeParms'] = document.ref
                Predictor: 15
                Colors: @image.colors
                BitsPerComponent: @image.bits
                Columns: @width
                
        if @image.palette.length is 0
            obj.data['ColorSpace'] = @image.colorSpace
        else
            # embed the color palette in the PDF as an object stream
            palette = document.ref
                Length: @image.palette.length

            palette.add new Buffer(@image.palette)

            # build the color space array for the image
            obj.data['ColorSpace'] = ['Indexed', 'DeviceRGB', (@image.palette.length / 3) - 1, palette]
            
        # For PNG color types 0, 2 and 3, the transparency data is stored in
        # a dedicated PNG chunk.
        if @image.transparency.grayscale
            # Use Color Key Masking (spec section 4.8.5)
            # An array with N elements, where N is two times the number of color components.
            val = @image.transparency.greyscale
            obj.data['Mask'] = [val, val]

        else if @image.transparency.rgb
            # Use Color Key Masking (spec section 4.8.5)
            # An array with N elements, where N is two times the number of color components.
            rgb = @image.transparency.rgb
            mask = []
            for x in rgb
                mask.push x, x

            obj.data['Mask'] = mask
            
        if @alphaChannel
            sMask = document.ref
                Type: 'XObject'
                Subtype: 'Image'
                Height: @height
                Width: @width
                BitsPerComponent: 8
                Length: @alphaChannel.length
                Filter: 'FlateDecode'
                ColorSpace: 'DeviceGray'
                Decode: [0, 1]

            sMask.add @alphaChannel
            obj.data['SMask'] = sMask

        # add the actual image data    
        obj.add @imgData
        fn obj
        
    splitAlphaChannel: (fn) ->
        @image.decodePixels (pixels) =>
            colorByteSize = @image.colors * @image.bits / 8
            pixelCount = @width * @height
            imgData = new Buffer(pixelCount * colorByteSize)
            alphaChannel = new Buffer(pixelCount)

            i = p = a = 0
            len = pixels.length
            while i < len
                imgData[p++] = pixels[i++]
                imgData[p++] = pixels[i++]
                imgData[p++] = pixels[i++]
                alphaChannel[a++] = pixels[i++]

            done = 0
            zlib.deflate imgData, (err, @imgData) =>
                throw err if err
                fn() if ++done is 2

            zlib.deflate alphaChannel, (err, @alphaChannel) =>
                throw err if err
                fn() if ++done is 2
                
    loadIndexedAlphaChannel: (fn) ->
        transparency = @image.transparency.indexed
        @image.decodePixels (pixels) =>
            alphaChannel = new Buffer(@width * @height)

            i = 0
            for j in [0...pixels.length] by 1
                alphaChannel[i++] = transparency[pixels[j]]

            zlib.deflate alphaChannel, (err, @alphaChannel) =>
                throw err if err
                fn()
                
module.exports = PNGImage