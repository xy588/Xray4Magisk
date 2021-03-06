#!/sbin/sh
#####################
# xray Customization
#####################
SKIPUNZIP=1

# prepare xray execute environment
ui_print "- Prepare xray execute environment."
mkdir -p /data/xray
mkdir -p /data/xray/dnscrypt-proxy
mkdir -p /data/xray/run
mkdir -p $MODPATH/scripts
mkdir -p $MODPATH/system/bin
mkdir -p $MODPATH/system/etc
# download latest xray core from official link
ui_print "- Connect official xray download link."
official_xray_link="https://github.com/XTLS/Xray-core/releases"
latest_xray_version=`curl -k -s -I "${official_xray_link}/latest" | grep -i location | grep -o "tag.*" | grep -o "v[0-9.]*"`
if [ "${latest_xray_version}" = "" ] ; then
  ui_print "Error: Connect official xray download link failed." 
  exit 1
fi
ui_print "- Download latest xray core ${latest_xray_version}-${ARCH}"
case "${ARCH}" in
  arm)
    download_xray_link="${official_xray_link}/download/${latest_xray_version}/xray-linux-arm32-v7a.zip"
    ;;
  arm64)
    download_xray_link="${official_xray_link}/download/${latest_xray_version}/xray-linux-arm64-v8a.zip"
    ;;
  x86)
    download_xray_link="${official_xray_link}/download/${latest_xray_version}/xray-linux-32.zip"
    ;;
  x64)
    download_xray_link="${official_xray_link}/download/${latest_xray_version}/xray-linux-64.zip"
    ;;
esac
download_xray_zip="/data/xray/run/xray-core.zip"
curl "${download_xray_link}" -k -L -o "${download_xray_zip}" >&2
if [ "$?" != "0" ] ; then
  ui_print "Error: Download xray core failed."
  exit 1
fi
# install xray execute file
ui_print "- Install xray core $ARCH execute files"
unzip -j -o "${download_xray_zip}" "geoip.dat" -d /data/xray >&2
unzip -j -o "${download_xray_zip}" "geosite.dat" -d /data/xray >&2
unzip -j -o "${download_xray_zip}" "xray" -d $MODPATH/system/bin >&2
unzip -j -o "${download_xray_zip}" "v2ctl" -d $MODPATH/system/bin >&2
unzip -j -o "${ZIPFILE}" 'xray/scripts/*' -d $MODPATH/scripts >&2
unzip -j -o "${ZIPFILE}" "xray/bin/$ARCH/dnscrypt-proxy" -d $MODPATH/system/bin >&2
unzip -j -o "${ZIPFILE}" 'service.sh' -d $MODPATH >&2
unzip -j -o "${ZIPFILE}" 'uninstall.sh' -d $MODPATH >&2
rm "${download_xray_zip}"
# copy xray data and config
ui_print "- Copy xray config and data files"
[ -f /data/xray/softap.list ] || \
echo "192.168.43.0/24" > /data/xray/softap.list
[ -f /data/xray/resolv.conf ] || \
unzip -j -o "${ZIPFILE}" "xray/etc/resolv.conf" -d /data/xray >&2
unzip -j -o "${ZIPFILE}" "xray/etc/config.json.template" -d /data/xray >&2
[ -f /data/xray/dnscrypt-proxy/dnscrypt-blacklist-domains.txt ] || \
unzip -j -o "${ZIPFILE}" 'xray/etc/dnscrypt-proxy/dnscrypt-blacklist-domains.txt' -d /data/xray/dnscrypt-proxy >&2
[ -f /data/xray/dnscrypt-proxy/dnscrypt-blacklist-ips.txt ] || \
unzip -j -o "${ZIPFILE}" 'xray/etc/dnscrypt-proxy/dnscrypt-blacklist-ips.txt' -d /data/xray/dnscrypt-proxy >&2
[ -f /data/xray/dnscrypt-proxy/dnscrypt-cloaking-rules.txt ] || \
unzip -j -o "${ZIPFILE}" 'xray/etc/dnscrypt-proxy/dnscrypt-cloaking-rules.txt' -d /data/xray/dnscrypt-proxy >&2
[ -f /data/xray/dnscrypt-proxy/dnscrypt-forwarding-rules.txt ] || \
unzip -j -o "${ZIPFILE}" 'xray/etc/dnscrypt-proxy/dnscrypt-forwarding-rules.txt' -d /data/xray/dnscrypt-proxy >&2
[ -f /data/xray/dnscrypt-proxy/dnscrypt-proxy.toml ] || \
unzip -j -o "${ZIPFILE}" 'xray/etc/dnscrypt-proxy/dnscrypt-proxy.toml' -d /data/xray/dnscrypt-proxy >&2
[ -f /data/xray/dnscrypt-proxy/dnscrypt-whitelist.txt ] || \
unzip -j -o "${ZIPFILE}" 'xray/etc/dnscrypt-proxy/dnscrypt-whitelist.txt' -d /data/xray/dnscrypt-proxy >&2
[ -f /data/xray/dnscrypt-proxy/example-dnscrypt-proxy.toml ] || \
unzip -j -o "${ZIPFILE}" 'xray/etc/dnscrypt-proxy/example-dnscrypt-proxy.toml' -d /data/xray/dnscrypt-proxy >&2
unzip -j -o "${ZIPFILE}" 'xray/etc/dnscrypt-proxy/update-rules.sh' -d /data/xray/dnscrypt-proxy >&2
[ -f /data/xray/config.json ] || \
cp /data/xray/config.json.template /data/xray/config.json
ln -s /data/xray/resolv.conf $MODPATH/system/etc/resolv.conf
# generate module.prop
ui_print "- Generate module.prop"
rm -rf $MODPATH/module.prop
touch $MODPATH/module.prop
echo "id=xray" > $MODPATH/module.prop
echo "name=xray for Android" >> $MODPATH/module.prop
echo -n "version=" >> $MODPATH/module.prop
echo ${latest_xray_version} >> $MODPATH/module.prop
echo "versionCode=20200918" >> $MODPATH/module.prop
echo "author=chendefine" >> $MODPATH/module.prop
echo "description=xray core with service scripts for Android" >> $MODPATH/module.prop

inet_uid="3003"
net_raw_uid="3004"
set_perm_recursive $MODPATH 0 0 0755 0644
set_perm  $MODPATH/service.sh    0  0  0755
set_perm  $MODPATH/uninstall.sh    0  0  0755
set_perm  $MODPATH/scripts/start.sh    0  0  0755
set_perm  $MODPATH/scripts/xray.inotify    0  0  0755
set_perm  $MODPATH/scripts/xray.service    0  0  0755
set_perm  $MODPATH/scripts/xray.tproxy     0  0  0755
set_perm  $MODPATH/scripts/dnscrypt-proxy.service   0  0  0755
set_perm  $MODPATH/system/bin/xray  ${inet_uid}  ${inet_uid}  0755
set_perm  $MODPATH/system/bin/v2ctl  ${inet_uid}  ${inet_uid}  0755
set_perm  /data/xray                ${inet_uid}  ${inet_uid}  0755
set_perm  $MODPATH/system/bin/dnscrypt-proxy ${net_raw_uid} ${net_raw_uid} 0755