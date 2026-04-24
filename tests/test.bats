setup() {
  set -eu -o pipefail
  export DIR="$( cd "$( dirname "$BATS_TEST_FILENAME" )" >/dev/null 2>&1 && pwd )/.."
  export PROJNAME="test-compass"
  export TESTDIR=~/tmp/$PROJNAME
  mkdir -p $TESTDIR
  export DDEV_NONINTERACTIVE=true
  ddev delete -Oy ${PROJNAME} >/dev/null 2>&1 || true
  cd "${TESTDIR}"
  ddev config --project-name=${PROJNAME} >/dev/null
}

teardown() {
  set -eu -o pipefail
  cd ${TESTDIR} || ( printf "unable to cd to ${TESTDIR}\n" && exit 1 )
  ddev delete -Oy ${PROJNAME} >/dev/null 2>&1
  [ "${TESTDIR}" != "" ] && rm -rf ${TESTDIR}
}

health_checks() {
  # Files installed
  [ -f "${TESTDIR}/.ddev/docker-compose.compass.yaml" ]
  [ -f "${TESTDIR}/.ddev/commands/host/compass" ]
  [ -x "${TESTDIR}/.ddev/commands/host/compass" ]

  # ddev-mongo was pulled in as a dependency
  [ -f "${TESTDIR}/.ddev/docker-compose.mongo.yaml" ]

  # mongo service's random host port is reachable
  run docker port ddev-${PROJNAME}-mongo 27017/tcp
  assert_success
  assert_output --partial ":"

  # The `ddev compass` command is registered and runnable
  run ddev help compass
  assert_success
  assert_output --partial "MongoDB Compass"
}

@test "install from directory" {
  set -eu -o pipefail
  cd ${TESTDIR}
  echo "# ddev add-on get ${DIR} with project ${PROJNAME} in ${TESTDIR} ($(pwd))" >&3
  ddev add-on get ${DIR}
  ddev restart >/dev/null
  health_checks
}

@test "install from release" {
  set -eu -o pipefail
  cd ${TESTDIR} || ( printf "unable to cd to ${TESTDIR}\n" && exit 1 )
  echo "# ddev add-on get pggns/ddev-compass with project ${PROJNAME} in ${TESTDIR} ($(pwd))" >&3
  ddev add-on get pggns/ddev-compass
  ddev restart >/dev/null
  health_checks
}
