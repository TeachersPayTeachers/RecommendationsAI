
#!/bin/bash
# Activate Google account, either from
# * GOOGLE_APPLICATION_CREDENTIALS
# * GOOGLE_APPLICATION_CREDENTIALS__B64
# If either exist, will ensure that GOOGLE_APPLICATION_CREDENTIALS
# exists.

if [ ! -z "${GOOGLE_APPLICATION_CREDENTIALS}" ]; then
  echo "Using GOOGLE_APPLICATION_CREDENTIALS"
elif [ ! -z "${GOOGLE_APPLICATION_CREDENTIALS__B64}" ]; then
  echo "Using GOOGLE_APPLICATION_CREDENTIALS__B64"
  export GOOGLE_APPLICATION_CREDENTIALS="$(mktemp -t gcp.json.XXXXXXXX)"
  echo "Set GOOGLE_APPLICATION_CREDENTIALS to ${GOOGLE_APPLICATION_CREDENTIALS}"
  echo -n "${GOOGLE_APPLICATION_CREDENTIALS__B64}" | base64 -d > "${GOOGLE_APPLICATION_CREDENTIALS}"
  if [ $? -ne 0 ]; then
    echo "Failed b64 decode"; exit 1
  fi
else
  >&2 echo "Neither GOOGLE_APPLICATION_CREDENTIALS or GOOGLE_APPLICATION_CREDENTIALS__B64 is set, google apps may not work"
fi

if [ ! -z "${GOOGLE_APPLICATION_CREDENTIALS}" ]; then
  echo "Activating google service account from key file ${GOOGLE_APPLICATION_CREDENTIALS}"
  gcloud auth activate-service-account --key-file="${GOOGLE_APPLICATION_CREDENTIALS}"
  if [ $? -ne 0 ]; then
    echo "Failed gcloud activate"; exit 1
  fi
  echo "Activation is complete"
else
  >&2 echo "GOOGLE_APPLICATION_CREDENTIALS was never set"
fi
