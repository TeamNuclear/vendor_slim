#!/sbin/sh
#
# Backup and restore addon /system files
#

export C=/tmp/backupdir
export S=/system
export V=Slim-5.1

# Scripts in /system/addon.d expect to find backuptool.functions in /tmp
cp -f /tmp/install/bin/backuptool.functions /tmp

# Preserve /system/addon.d in /tmp/addon.d
preserve_addon_d() {
  mkdir -p /tmp/addon.d/
  cp -a /system/addon.d/* /tmp/addon.d/
  chmod 755 /tmp/addon.d/*.sh
}

# Restore /system/addon.d in /tmp/addon.d
restore_addon_d() {
  cp -a /tmp/addon.d/* /system/addon.d/
  rm -rf /tmp/addon.d/
}

# Execute /system/addon.d/*.sh scripts with $1 parameter
run_stage() {
for script in $(find /tmp/addon.d/ -name '*.sh' |sort -n); do
  $script $1
done
}

case "$1" in
  backup)
    mkdir -p $C
    if check_prereq; then
        if check_whitelist system; then
            exit 127
        fi
    fi
    check_blacklist system
    preserve_addon_d
    run_stage pre-backup
    run_stage backup
    run_stage post-backup
  ;;
  restore)
    if check_prereq; then
        if check_whitelist tmp; then
            exit 127
        fi
    fi
    check_blacklist tmp
    run_stage pre-restore
    run_stage restore
    run_stage post-restore
    restore_addon_d
    rm -rf $C
    sync
  ;;
  *)
    echo "Usage: $0 {backup|restore}"
    exit 1
esac

exit 0
