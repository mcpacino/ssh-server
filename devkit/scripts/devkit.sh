#!/usr/bin/env bash

# CLI Usage
# devkit.sh  run     PROJECT      TARGET    [EDGE_KEY]       # PROJECT=portainer|agent|edge   TARGET=docker|swarm|k8s|workspace
# devkit.sh  dlv     exec|kill    PROJECT   ENV_VAR_LIST     # PROJECT=portainer|agent|edge   ENV_VAR_LIST=DLV_PORT:DATA_PATH:EDGE_KEY:DEVKIT_DEBUG
# devkit.sh  init                                            #
# devkit.sh  ensure  TARGET                                  # TARGET=docker|swarm|k8s|workspace|network
# devkit.sh  clean   targets|all                             #


#echo "🏁️ $COMMAND $PROJECT in $TARGET..." && echo

_init() {
  CURRENT_FILE_PATH=$(dirname $0)   # /home/workspace/portainer-devkit/devkit/scripts

  source "${CURRENT_FILE_PATH}/libs/consts.sh"
  source "${CURRENT_FILE_PATH}/libs/helpers.sh"
  source "${CURRENT_FILE_PATH}/libs/ensure/ensure_network.sh"
  source "${CURRENT_FILE_PATH}/libs/ensure/ensure_workspace.sh"
  source "${CURRENT_FILE_PATH}/libs/ensure/ensure_k8s.sh"
  source "${CURRENT_FILE_PATH}/libs/ensure/ensure_k8s_agent.sh"
  source "${CURRENT_FILE_PATH}/libs/ensure/ensure_webpack.sh"
  source "${CURRENT_FILE_PATH}/libs/rpc/rpc.sh"
  source "${CURRENT_FILE_PATH}/libs/rpc/rpc_dlv.sh"
  source "${CURRENT_FILE_PATH}/libs/rpc/rpc_kill_dlv.sh"
  source "${CURRENT_FILE_PATH}/libs/cmd/cmd_run.sh"
  source "${CURRENT_FILE_PATH}/libs/cmd/cmd_dlv.sh"
  source "${CURRENT_FILE_PATH}/libs/run/run_portainer.sh"
  source "${CURRENT_FILE_PATH}/libs/build/build_portainer.sh"
  source "${CURRENT_FILE_PATH}/libs/rsync/rsync_portainer.sh"
  source "${CURRENT_FILE_PATH}/libs/dlv/dlv_portainer.sh"
  source "${CURRENT_FILE_PATH}/libs/init/init_args.sh"
  source "${CURRENT_FILE_PATH}/libs/init/init_common_vars.sh"
  source "${CURRENT_FILE_PATH}/libs/init/init_cmd_run_vars.sh"

  init_args "$@"
  init_common_vars
}
_init "$@"


runXX() {
  case $PROJECT in
  portainer)
    run_portainer $PROJECT_VER "$TARGET"
    ;;
  agent)
    run_agent "$TARGET" "$PROJECT"
    ;;
  edge-agent)
    run_agent "$TARGET" "$PROJECT" "$EDGE_KEY"
    ;;
  *)
    echo "❌ Unknown Project $PROJECT"
    exit 2
    ;;
  esac
}

_clean() {
  docker stop "$TARGET_NAME_K8S_CONTAINER" >>"$STDOUT" 2>&1  &&  docker rm "$TARGET_NAME_K8S_CONTAINER" >>"$STDOUT" 2>&1
  docker stop "$TARGET_SWARM" >>"$STDOUT" 2>&1
  docker stop "$TARGET_NAME_DOCKER" >>"$STDOUT" 2>&1
  docker stop "$DEVKIT_NAME" >>"$STDOUT" 2>&1
  echo "Removed all targets"
}

_ensure() {
  if [[ $PROJECT == "network" ]]; then
    ensure_network
  elif [[ "$PROJECT" == "workspace" ]]; then
    ensure_workspace
  fi
}

main() {
  case $COMMAND in
  run)
    init_cmd_run_vars
    cmd_run
    ;;
  dlv)
    cmd_dlv
    ;;
  ensure)
    _ensure
    ;;
  clean)
    _clean
    ;;
  *)
    echo "❌ Unknown command"
    exit 1
    ;;
  esac
}

main