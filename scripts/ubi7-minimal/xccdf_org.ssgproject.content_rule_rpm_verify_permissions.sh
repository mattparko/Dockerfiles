#!/bin/sh
set -e

###############################################################################
# BEGIN fix for 'xccdf_org.ssgproject.content_rule_rpm_verify_permissions'
###############################################################################
(>&2 echo "Remediating: 'xccdf_org.ssgproject.content_rule_rpm_verify_permissions'")

# Declare array to hold list of RPM packages we need to correct permissions for
declare -a SETPERMS_RPM_LIST

# Create a list of files on the system having permissions different from what
# is expected by the RPM database
FILES_WITH_INCORRECT_PERMS=($(rpm -Va --nofiledigest | grep '^.M' | cut -d ' ' -f4-))

# For each file path from that list:
# * Determine the RPM package the file path is shipped by,
# * Include it into SETPERMS_RPM_LIST array

for FILE_PATH in "${FILES_WITH_INCORRECT_PERMS[@]}"
do
	RPM_PACKAGE=$(rpm -qf "$FILE_PATH")
	SETPERMS_RPM_LIST=("${SETPERMS_RPM_LIST[@]}" "$RPM_PACKAGE")
done

# Remove duplicate mention of same RPM in $SETPERMS_RPM_LIST (if any)
SETPERMS_RPM_LIST=( $(echo "${SETPERMS_RPM_LIST[@]}" | tr ' ' '\n' | sort -u | tr '\n' ' ') )

# For each of the RPM packages left in the list -- reset its permissions to the
# correct values
for RPM_PACKAGE in "${SETPERMS_RPM_LIST[@]}"
do
	rpm --quiet --setperms "${RPM_PACKAGE}"
done
# END fix for 'xccdf_org.ssgproject.content_rule_rpm_verify_permissions'