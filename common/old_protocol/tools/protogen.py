import getopt
import sys
import libxslt
import libxml2

class Config:
    pass

config = Config()

def show_help():
    print "Usage : protogen.py --help --xmlinput=file.xml -v --lang=[erl, js]"

def main():
    # get options
    opts, args = getopt.getopt(sys.argv[1:], "hx:vl:o:", ["help", "xmlinput=", "output=", "lang="])
    #traverse through options
    config.verbose = False
    config.xmlInput = "proto.xml"
    config.lang = "erlang"
    config.output = "proto.erl"
    for opt, arg in opts:
        if opt == "-v":
            config.verbose = True
        if opt in ("-h", "--help"):
            show_help()
        if opt in ("-x", "--xmlinput"):
            config.xmlInput = arg
        if opt in ("-o", "--output"):
            config.output = arg
        if opt in ("-l", "--lang"):
            config.lang = arg
    # generate protocol
    generate_protocol(config.xmlInput, config.output, config.lang)
    print "Bye! =)"



def generate_protocol(xmlInput, output, lang):
    print "[i] generating new protocol"
    print "[i] protocol xml file is " + xmlInput
    print "[i] selected language is " + lang
    print "[i] result will be writed to " + output
    print "[i] parsing files..."
    generator = "./generators/" + lang + ".xslt"
    xmldoc = libxml2.parseFile(xmlInput)
    styledoc = libxml2.parseFile(generator)
    style = libxslt.parseStylesheetDoc(styledoc)
    print "[i] applying stylesheet..."
    result = style.applyStylesheet(xmldoc, None)
    print "[i] writing the result..."
    style.saveResultToFilename(output, result, 0)
    print "[i] cleanup..."
    xmldoc.freeDoc()
    style.freeStylesheet()
    result.freeDoc()
    
    




main()
