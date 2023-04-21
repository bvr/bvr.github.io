
import fileinput
import argparse

cli = argparse.ArgumentParser(prog = 'generator', description = 'Builds summary spreadsheet')
# cli.add_argument('--reqdir',   help = 'directory with requirements', required=True)
cli.add_argument('--sections', help = 'csv file with sections. Default: %(default)s', default = 'sections.csv')
cli.add_argument('--matrix',   help = 'matrix file. Default: %(default)s', default = 'matrix.xls')
cli.add_argument('--safety',   help = 'safety requirements file. Default: %(default)s', default = 'safety.xls')
cli.add_argument('-v', '--verbose', help = 'verbose output', action='store_true')
cli.add_argument('files', metavar='FILE', nargs='*', help='files to read, if empty, stdin is used')

args = cli.parse_args()
print("Runtime Args=%s" % args)

for line in fileinput.input():
    print(fileinput.filename() + "[" + str(fileinput.filelineno()) + "]:" + line.rstrip())
