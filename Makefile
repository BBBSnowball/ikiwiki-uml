LOCALPATH := ~/.ikiwiki/IkiWiki/Plugin/

PLUGINPATH := IkiWiki/Plugin

plugins = ${PLUGINPATH}/plantuml.pm ${PLUGINPATH}/plantuml.jar
local: ${plugins}
	mkdir -p ${LOCALPATH}
	cp ${plugins} ${LOCALPATH}

${PLUGINPATH}/plantuml.jar:
	curl -o $@ -L -O https://github.com/plantuml/plantuml/releases/download/v1.2022.12/plantuml.jar

PlantUML_Language_Reference_Guide.pdf:
	curl -L -O http://plantuml.com/PlantUML_Language_Reference_Guide.pdf

reference: PlantUML_Language_Reference_Guide.pdf
