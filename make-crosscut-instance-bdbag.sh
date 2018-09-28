#!/bin/tcsh

setenv PYTHONPATH ./

# Script to create the crosscut metadata model instance. 
#
# The public or non-access-restricted crosscut metadata model instance is a
# BDBag that contains DATS JSON-LD files that describe the metadata from the 
# following resources:
#
# 1. Public GTEx v7 metadata from dbGaP and the GTEx portal.
# 2. Public TOPMed metadata from non-access-restricted dbGaP files.
# 
# In the case of both GTEx and TOPMed the crosscut metadata model instance may 
# be expanded to include access-restricted dbGaP metadata (see the relevant script 
# invocation below) but this expanded instance may not be publicly distributed.

setenv VERSION 0.7
setenv EXTERNAL_ID "KC7-crosscut-metadata-v${VERSION}"
setenv EXTERNAL_DESCR "v${VERSION} release of the KC7 crosscut metadata model for GTEx v7 and TOPMed public metadata using DATS v2.2+"

# set up internal bag structure
mkdir -p $EXTERNAL_ID/docs
mkdir -p $EXTERNAL_ID/datasets

## -----------------------------------------------
## Public GTEx v7 dbGaP metadata
## -----------------------------------------------

# Convert public dbGaP metadata for GTEx to DATS JSON.
#
# First retrieve the pheno_variable_summaries files for GTEx into a local directory:
#  1. create local directory dbgap-data if it does not already exist
#  2. pull ftp://ftp.ncbi.nlm.nih.gov/dbgap/studies/phs000424/phs000424.v7.p2/pheno_variable_summaries/ into dbgap-data/phs000424.v7.p2
#
# Then make sure the dcppc/data-stewards repo is cloned or downloaded locally:
#  3. git clone https://github.com/dcppc/data-stewards.git
#  4. modify --data_stewards_repo_path accordingly
# 
#  5. Run the command below

./bin/gtex_v7_to_dats.py --dbgap_public_xml_path=./dbgap-data/phs000424.v7.p2 \
  --data_stewards_repo_path=./data-stewards \
  --output_file=$EXTERNAL_ID/datasets/GTEx_v7_public.jsonld 

# Command used to create instance for validation. Due to limitations with the current DATS
# validator, the following 2 changes must be applied to generate an instance that can 
# pass validation:
#
#  1. Run gtex_v7_to_dats.py with the --no_circular_links flag
#  2. Set datsobj.DEBUG_NO_ID_REFS to True (for both GTEx and TOPMed)
#
#./bin/gtex_v7_to_dats.py --dbgap_public_xml_path=./dbgap-data/phs000424.v7.p2 \
#  --data_stewards_repo_path=./data-stewards \
#  --no_circular_links \
#  --output_file=$EXTERNAL_ID/datasets/GTEx_v7_public_no_cycles.jsonld 

## -----------------------------------------------
## RESTRICTED ACCESS GTEx v7 dbGaP metadata
## -----------------------------------------------

# Convert RESTRICTED ACCESS dbGaP metadata for GTEx to DATS JSON.

#./bin/dbgap_gtex_to_dats.py --dbgap_public_xml_path=./dbgap-data/phs000424.v7.p2 \
#  --dbgap_protected_metadata_path=./restricted-access-dbgap-data/phs000424.v7.p2 \
#  --data_stewards_repo_path=./data-stewards \
#  --output_file=$EXTERNAL_ID/datasets/GTEx_v7_RESTRICTED.jsonld

## -----------------------------------------------
## Public TOPMed metadata
## -----------------------------------------------

# Convert public dbGaP metadata for selected TOPMed studies to DATS JSON.
#
# First retrieve the pheno_variable_summaries from the desired TOPMed studies into a local directory: 
#  1. create local directory dbgap-data if it does not already exist
#  2. pull ftp://ftp.ncbi.nlm.nih.gov/dbgap/studies/phs001024/phs001024.v3.p1/pheno_variable_summaries/ into dbgap-data/phs001024.v3.p1
#  3. pull ftp://ftp.ncbi.nlm.nih.gov/dbgap/studies/phs000951/phs000951.v2.p2/pheno_variable_summaries/ into dbgap-data/phs000951.v2.p2
#  4. pull ftp://ftp.ncbi.nlm.nih.gov/dbgap/studies/phs000179/phs000179.v5.p2/pheno_variable_summaries/ into dbgap-data/phs000179.v5.p2
#  5. run the command below

./bin/topmed_to_dats.py --dbgap_accession_list='phs001024.v3.p1,phs000951.v2.p2,phs000179.v5.p2' \
  --dbgap_public_xml_path=./dbgap-data \
  --output_file=$EXTERNAL_ID/datasets/TOPMed_phs000951_phs000946_phs001024_wgs_public.jsonld

## -----------------------------------------------
## RESTRICTED ACCESS TOPMed metadata
## -----------------------------------------------

# Convert RESTRICTED ACCESS TOPMed metadata to DATS JSON.

#./bin/topmed_to_dats.py --dbgap_accession_list='phs001024.v3.p1,phs000951.v2.p2,phs000179.v5.p2' \
#  --dbgap_public_xml_path=./dbgap-data \
#  --dbgap_protected_metadata_path=./restricted-access-dbgap-data \
#  --output_file=$EXTERNAL_ID/datasets/TOPMed_phs000951_phs000946_phs001024_wgs_RESTRICTED.jsonld

## -----------------------------------------------
## Add documentation
## -----------------------------------------------

cp releases/ChangeLog $EXTERNAL_ID/docs/
cp RELEASE_NOTES $EXTERNAL_ID/docs/

## -----------------------------------------------
## Create BDBag
## -----------------------------------------------

bdbag --archive tgz \
 --source-organization 'NIH DCPPC KC7 Working Group' \
 --contact-name 'Jonathan Crabtree' \
 --contact-email 'jcrabtree@som.umaryland.edu' \
 --external-description "$EXTERNAL_DESCR" \
 --external-identifier $EXTERNAL_ID \
$EXTERNAL_ID

## -----------------------------------------------
## Validate BDBag
## -----------------------------------------------

bdbag --validate full $EXTERNAL_ID.tgz
