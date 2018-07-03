import sys
def xor_string(path, string_to_find, key):
    print "PYTHON: Xoring password in file: %s" % path
    with open(path, 'r+b') as f:
        file_content = f.read()
        offset_str = file_content.find(string_to_find)
        print "Offset found 0x%x for %s" % (offset_str, string_to_find)
        if offset_str > 0:
            f.seek(offset_str)
            for i in range(0,len(string_to_find)):
                f.write(chr(ord(string_to_find[i]) ^ key))

parameters = {
    "xor": lambda arg: xor_string(arg[2], arg[3], int(arg[4], 16))
}

parameters[sys.argv[1]](sys.argv)