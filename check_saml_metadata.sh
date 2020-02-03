#!/bin/bash

check_file () {
    "${XMLSECTOOL}" --validateSchema --schemaDirectory "${SCHEMA_DIR}" \
        --logConfig "${LOGGER_CONF}"  --inFile "$1"
}

main () {
    if [ -z "${JAVA_HOME}" ]; then
        echo "JAVA_HOME was not set, trying to determine the right value..."
        JAVA_CMD=`which java`
        if [ ! -z ${JAVA_CMD} ]; then
            # slightly hack approach for guessing java
            JAVA_CMD=`readlink -f "${JAVA_CMD}"`
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
        echo "Trying JAVA_HOME value: ${JAVA_HOME}"
        echo "If this fails, set JAVA_HOME to the directory containing your bin/java"
    else
        echo "JAVA_HOME already set, value: ${JAVA_HOME}"
    fi

    if [ -z "${JAVA_HOME}" ]; then
        echo "*** ERROR: cannot determine JAVA_HOME"
        echo "Please set JAVA_HOME environment variable the correct location and try again."
        echo "Example: export JAVA_HOME=/usr/lib/jvm/java-1.7.0*/j??/ # contains bin/java..."
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
        echo "*** ERROR: mandatory file or directory path omitted."
        exit 1
    fi

    LOGGER_CONF="${BASE_DIR}/logger.xml"
    echo "${LOGGER_CONF}"

    FAILED_FILES=()

    if  [ -f "${1}" ]; then
        echo "Checking single file: $(realpath ${1})"
        check_file ${1}
    else if [ -d "${1}" ]; then
        echo "Checking all files in directory: $(realpath ${1})"
        FILES="${1}"/*.xml
        for file in ${FILES}
        do
            echo "Processing file: $(realpath ${file})... "
            if ! check_file ${file}; then
                FAILED_FILES+=( "$(basename ${file})" )
            fi
        done
        echo "Merging all SP metadata files into a single metadata output..."
        ((xmllint -xpath "/*[local-name()='EntitiesDescriptor' and namespace-uri()='urn:oasis:names:tc:SAML:2.0:metadata']" CI-assets/feed_wrapper.xml  | \
            head -1; xmllint -xpath "/*[local-name()='EntityDescriptor' and namespace-uri()='urn:oasis:names:tc:SAML:2.0:metadata']" metadata/*;tail -1 CI-assets/feed_wrapper.xml) | \
            xmllint --nsclean --format -) > aggregated_feed.xml
        echo "Processing merged output..."
        if ! check_file aggregated_feed.xml; then
            FAILED_FILES+=( "Merged XML output" )
        fi
        rm aggregated_feed.xml
        else
            echo "Invalid input. \"${1}\" is not a file nor a directory."
            exit 1
        fi
    fi
    if [ ${#FAILED_FILES[@]} -gt 0 ]; then
        printf "\n[REPORT] The following file(s) failed validation and need to be repaired [REPORT]\n"
        for file in ${FAILED_FILES[@]}
        do
            echo "- ${file}"
        done
        echo ""
        exit ${#FAILED_FILES[@]}
    fi
    echo ""
    exit 0
}

main "$@"; exit
