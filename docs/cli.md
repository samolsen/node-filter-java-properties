## CLI

A simple CLI for filtering files is provided in `bin/filter-java-properties`.

The basic syntax: 

```sh
filter-java-properties $PROPERTIES_FILE $FILTER_SOURCE
```

Without passing options, the source is filtered with the default delimiters and sent to `stdout`.

Supported options:

`--outpath` or `-o` file path where the filtered file should be written

`--delimiter` or `-d` delimiter to use for filtering. This option may be used multiple times.

`--encoding` encoding for the output file, default `'utf8'`
