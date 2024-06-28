# Type a script or drag a script file from your workspace to insert its path.
# dart-defines配置方法
echo "获取DART_DEFINES"
function urldecode() {
  : "${*//+/ }"
  echo "${_//%/\\x}"
}

IFS=',' read -r -a define_items <<<"$DART_DEFINES"

for index in "${!define_items[@]}"; do
  item=$(base64 -d <<<"${define_items[$index]}")
  define_items[$index]=$(urldecode "$item")
done

filter1='flutter.inspector.structuredErrors'
filter2='FLUTTER_WEB_AUTO_DETECT'
envKey="ENV="
env='dev'

for index in "${!define_items[@]}"; do
  item="${define_items[$index]}"
  if [[ $item == *$filter1* || $item == *$filter2* ]]; then
    unset define_items[$index]
    echo '包含过滤数据，已被删除'
  elif [[ $item == *$envKey* ]]; then
    env=${define_items[$index]//$envKey/}
    echo '获取到环境配置信息'
  else
    echo "不包含"
  fi
done

echo "读取的配置为：$define_items"
echo "当前环境为$env"

stageEnv='stage'
releaseEnv='release'
configFileName='.env.dev'

if [[ $env == $releaseEnv ]]; then
  configFileName='.env.release'
  echo '配置为正式环境'
elif [[ $env == $stageEnv ]]; then
  configFileName='.env.stage'
  echo '配置为演示环境'
else
  echo "配置为开发环境"
fi

http='http://'
https='https://'

replaceHttp='http:/$()/'
replaceHttps='https:/$()/'

infos=$(cat "${SRCROOT}/../assets/config/${configFileName}")
echo "处理前数据"
echo $infos

configs=()
for item in $infos; do
  newItem=$item
  if [[ $item == *$http* ]]; then
    newItem=${item/$http/$replaceHttp}
    echo "包含http://，已替换为${newItem}"
  elif [[ $item == *$https* ]]; then
    newItem=${item/$https/$replaceHttps}
    echo "包含https://，已替换为${newItem}"
  else
    echo "不包含"
  fi
  configs+=("$newItem")
done
configs=${configs[@]}
echo "处理后数据"
echo $configs
echo "写入Configs.xcconfig"
printf "%s\n" "${define_items[@]}" >${SRCROOT}/Flutter/Configs.xcconfig
configs=${configs[@]}
for i in $configs; do
  printf "%s\n" "$i" >>${SRCROOT}/Flutter/Configs.xcconfig
done

echo "修改Debug/Release.xcconfig"
configValue1="#include \"Generated.xcconfig\""
configValue2="#include \"Configs.xcconfig\""
printf "%s\n%s\n%s" '#include? "Pods/Target Support Files/Pods-Runner/Pods-Runner.debug.xcconfig"' "$configValue1" "$configValue2" >${SRCROOT}/Flutter/Debug.xcconfig
printf "%s\n%s\n%s" '#include? "Pods/Target Support Files/Pods-Runner/Pods-Runner.release.xcconfig"' "$configValue1" "$configValue2" >${SRCROOT}/Flutter/Release.xcconfig

plist=${PROJECT_DIR}/${INFOPLIST_FILE}

for line in $(cat ${SRCROOT}/Flutter/Configs.xcconfig); do
  key=$(echo ${line%%=*})
  /usr/libexec/Plistbuddy -c "Add $key string \${$key}" "${plist}"
done

# CFBundleVersion自增方法
if [ $CONFIGURATION == Release ]; then
  echo "配置CFBundleVersion"

  buildNum=$(/usr/libexec/PlistBuddy -c "Print CFBundleVersion" "${plist}")

  if [[ "${buildNum}" == "" ]]; then
    echo "info.plist中不存在CFBundleVersion，默认为1"
    buildNum=1
  fi
  echo "当前CFBundleVersion为$buildNum"
  buildNum=$(expr $buildNum + 1)
  echo "CFBundleVersion升级后为$buildNum"

  /usr/libexec/Plistbuddy -c "Set CFBundleVersion $buildNum" "${plist}"

  echo "配置CFBundleVersion完成"

else
  echo $CONFIGURATION " 无需配置CFBundleVersion"
fi
