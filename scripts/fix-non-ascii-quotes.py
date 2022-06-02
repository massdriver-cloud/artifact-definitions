#!/usr/bin/env python3
import re
import sys

unicode_single_quotes_pattern = re.compile(r"[\u2018\u2019]", re.U)

unicode_double_quotes_pattern = re.compile(r"[\u201C\u201D]", re.U)

filename = sys.argv[1]

with open(filename, "r+") as f:
    contents = f.read()
    fixed_contents = re.sub(unicode_single_quotes_pattern, "'", contents)
    fixed_contents = re.sub(unicode_double_quotes_pattern, '\\"', fixed_contents)
    # overwrite the data in the file
    f.seek(0)
    f.write(fixed_contents)
    f.truncate()
