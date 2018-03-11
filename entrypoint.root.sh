#!/bin/sh

usermod -u $(stat -c %u /srv/working) user &&
    su -c "sh /opt/scripts/entrypoint.user.sh" user