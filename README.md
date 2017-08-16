# SAML-metadata-checker script
Please validate your SP's SAML metadata  with this script.
This script will be automatically run on every pull request for the [SPF-SPs-metadata repository](https://github.com/clarin-eric/SPF-SPs-metadata).

## To run locally
The script should be plug and play, so on Unix/Linux you can use:
$ ./check-saml-metadata/check_saml_metadata.sh  clarin-sp-metadata.xml

If the check_saml_metadata.sh does not guess JAVA_HOME correctly,
please set it explictly, e.g.
$ export JAVA_HOME=/you/path/to/jre
