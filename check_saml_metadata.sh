#!/bin/sh

if [ -z "${JAVA_HOME}" ]; then
    JAVA_CMD=`which java`
    if [ ! -z ${JAVA_CMD} ]; then
    	# slightly hack approach for guessing java
    	JAVA_CMD=`readlink "${JAVA_CMD}"`
    	# strip java cmd
    	JAVA_CMD=`dirname "${JAVA_CMD}"`
    	# strip bin directory
    	JAVA_HOME=`dirname "${JAVA_CMD}"`
    	if [ ! -d "${JAVA_HOME}" ]; then
    		JAVA_HOME=""
    	fi
    	export JAVA_HOME
    else
        if [ -d /usr/java/default ]; then
            export JAVA_HOME=/usr/java/default
        fi
    fi
fi
if [ -z "${JAVA_HOME}" ]; then
    echo "*** ERROR: cannot determine JAVA_HOME"
    echo "Please set JAVA_HOME environment variable the correct location and try again."
    exit 2
fi

BASE_DIR=`dirname $0`
SCHEMA_DIR="${BASE_DIR}/saml-schema"
XMLSECTOOL="${BASE_DIR}/xmlsectool/xmlsectool.sh"

if [ ! -d "${SCHEMA_DIR}" ]; then
    echo "*** ERROR: cannot determine saml-schema dir."
    exit 2
fi
if [ ! -x "${XMLSECTOOL}" ]; then
    echo "*** ERROR: cannot determine xmlsectool executable."
    exit 2
fi

if [ -z "$1" ]; then
    echo "*** ERROR: mandatory filename omitted."
    exit 1
fi

LOGGER_CONF="${BASE_DIR}/logger.xml"
echo "${LOGGER_CONF}"

exec "${XMLSECTOOL}" --validateSchema --schemaDirectory "${SCHEMA_DIR}" \
    --logConfig "${LOGGER_CONF}"  --inFile "$1"
