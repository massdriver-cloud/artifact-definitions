#!/usr/bin/env python3
import re
import sys

unicode_single_quotes_pattern = re.compile(r"[\u2018\u2019]", re.U)

unicode_double_quotes_pattern = re.compile(r"[\u201C\u201D]", re.U)

filename = sys.argv[1]

with open(filename, "r+") as f:
    contents = f.read()
    fixed_contents = unicode_single_quotes_pattern.sub("'", contents)
    fixed_contents = unicode_double_quotes_pattern.sub('\\"', fixed_contents)
    if fixed_contents == contents:
        # nothing to fix we're done
        sys.exit(0)
    # overwrite the data in the file
    f.seek(0)
    f.write(fixed_contents)
    f.truncate()
print(f"fixed non-ascii quotes in {filename}")
# need to exit 1 to tell pre-commit that we fixed something
sys.exit(1)
