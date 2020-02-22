import platform
import sys

def main():
    system = platform.system()
    if system == "Darwin":
        print('darwin')
        sys.exit()
    elif system == "Linux":
        print('linux')
        sys.exit()

    sys.exit("Unsupported system: %s" % system)

if __name__ == '__main__':
    main()