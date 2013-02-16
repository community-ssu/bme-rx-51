description "starting bme"
author "Pali Rohár"

console output

start on started dsme

env LOGGER='/usr/bin/logger -s -tBME'

script
  set +e
  $LOGGER -pdaemon.notice 'pre-start'

  case $(cat /tmp/STATE) in
  USER)
        if [ -e /var/lib/ke-recv/usb_phonet_mode ]; then
          modprobe g_nokia || true
          initctl emit G_NOKIA_READY
        else
          modprobe g_file_storage luns=2 stall=0 removable || \
            modprobe g_mass_storage luns=2 stall=0 removable=1,1 || \
            true
        fi
        ;;
  ACT_DEAD)
        modprobe g_file_storage luns=2 stall=0 removable || \
          modprobe g_mass_storage luns=2 stall=0 removable=1,1 || \
          true
        ;;
  *)
        $LOGGER -pdaemon.notice 'skip modprobe g_*'
        ;;
  esac

  if ! /usr/sbin/waitfordsme ; then
     $LOGGER -pdaemon.crit 'waitfordsme failed'
     exit 1
  fi

  if ! modprobe bq2415x_charger ; then
     $LOGGER -pdaemon.crit 'modprobe bq2415x_charger failed'
  fi

  if ! modprobe bq27x00_battery ; then
     $LOGGER -pdaemon.crit 'modprobe bq27x00_battery failed'
  fi

  if ! modprobe rx51_battery ; then
     $LOGGER -pdaemon.crit 'modprobe rx51_battery failed'
  fi
end script
