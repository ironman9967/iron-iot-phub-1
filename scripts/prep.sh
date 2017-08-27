#!/bin/bash

source $APP_PATH/common/scripts/start-nvm.sh

echo 'getting node version from cloud'
nodeVersion=`wget -qO- $CLOUD_URI/api/bin/versions/phub/1/interpreter/version`
echo "node version is $nodeVersion"

echo "installing node $nodeVersion"
nvm install "$nodeVersion"

echo "setting nvm default to $nodeVersion"
nvm alias default "$nodeVersion"

echo "setting nvm to use $nodeVersion"
nvm use "$nodeVersion"

echo "getting app version from $CLOUD_URI/api/bin/versions/phub/1/app/version"
version=`wget -qO- $CLOUD_URI/api/bin/versions/phub/1/app/version`
echo "app version is $version"

builtTar=built_phub-1_app_$version.tar.gz
echo "trying to download $version release from $CLOUD_URI/bin/devices/builds/phub/1/app/$builtTar"
wget -O $APP_PATH/$builtTar $CLOUD_URI/bin/devices/builds/phub/1/app/$builtTar

if [ $? == 0 ]
then
	echo "built release $version downloaded successfully from cloud"

	echo "extracting release $APP_PATH/$builtTar"
	tar xzf $APP_PATH/$builtTar --transform s:[^/]*:: -C $APP_PATH

	if [ $? == 0 ]
	then
		rm $APP_PATH/$builtTar
	else
		echo "ERROR: release $version failed to extract: $APP_PATH/$builtTar"
		exit 1
	fi
else
	echo "$version not built"
	echo "getting app for phub 1"
	wget -O $APP_PATH/get-app.sh "https://raw.githubusercontent.com/ironman9967/iron-iot-common/master/scripts/get-app.sh"
	source $APP_PATH/get-app.sh $APP_PATH phub 1

	source $APP_PATH/common/scripts/build-app.sh $APP_PATH $version phub 1

	rm -rf $APP_PATH/get-app.sh
fi

mkdir -p $APP_PATH/dist/builds
chmod 777 $APP_PATH/dist/builds
