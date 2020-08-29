#!/bin/bash
json-to-plantuml $PWD/schema.json | java -DPLANTUML_LIMIT_SIZE=32768 -Xmx3072m -jar $HOME/jar/plantuml.jar -pipe -tsvg > .svg

