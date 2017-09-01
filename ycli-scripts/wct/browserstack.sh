#!/bin/bash

#
# Bash Autocomplete
#
if [ "$1" == "ycliCommands" ]; then
	ycliCommands=("login list");
	_ycliAddCommandsForPath "wct/browserstack-configs";
	echo "${ycliCommands[@]}";
	return;
fi
if [ "$2" == "ycliCommands" ]; then
	return;
fi

if [[ -z ${ycliWctResultFilePath} ]]; then
	ycliWctResultFilePath=$(ycli config get wct.resultFilePath);
fi

optionSave=0;
optionSaveFilePath="$ycliWctResultFilePath";
optionConfigFilePath="";
parameters=($@);
i=0;
for parameter in ${parameters[@]}; do
	((i++));
	if [[ "$parameter" == "--config" || "$parameter" == "-c" ]]; then
		n=$((i+1));
		optionConfigFilePath=${!n};
		unset parameters[$(( i - 1 ))];
		unset parameters[$(( i ))];
	fi
	if [[ "$parameter" == "--save" || "$parameter" == "-s" ]]; then
		optionSave=1;
		unset parameters[$(( i - 1 ))];
	fi
	if [[ "$parameter" == "--save-file-path" || "$parameter" == "-f" ]]; then
		n=$((i+1));
		optionSaveFilePath=${!n};
		unset parameters[$(( i - 1 ))];
		unset parameters[$(( i ))];
	fi
	if [[ "$parameter" == "--help" ]]; then
		echo "";
		echo "Browserstack Testing";
		echo "";
		echo "This allows you to run the elements test via BrowserStack.";
		echo "";
		echo "Commands:";
		echo "  config/configFile: "
		echo "    Either a predefined config (see with <tab> <tab>) or a full path to a config "
		echo "  login: "
		echo "    Reenter your BrowserStack credential";
		echo "  list: ";
		echo "    Fetching an up to date browser list from BrowserStack via curl"
		echo "    See spec for api https://github.com/browserstack/api";
		echo "";
		echo "Options:";
		echo "  -s --save: ";
		echo "    save the output of BrowserStack to a file";
		echo "  -f --save-file-path: ";
		echo "    where to save the output [Defaults to '.tmp/_lastBrowserStackTestResult.txt']";
		echo "";
		echo "Examples:";
		echo "  browserstack chrome-latest-windows-10";
		echo "    => run the tests only for latest chrome on windows 10";
		echo "  browserstack ./other.wct.conf.js";
		echo "    => run test using other.wct.conf.js";
		echo "  browserstack --save";
		echo "    => runs the test and saves the output to the file";
		echo "  browserstack list > browsers.json";
		echo "    => fetches latest browser list and saves it to a file";
		echo "";
		return;
	fi
done

npmRoot=$(npm root -g);
webComponentTesterCustomRunnerPath="$npmRoot/web-component-tester-custom-runner"
wctBrowserstack="$npmRoot/wct-browserstack"

if [[ ! -d "$webComponentTesterCustomRunnerPath" || ! -d "$wctBrowserstack" ]]; then
	echo "[ERROR] Not properly installed";
	echo "You have to run";
	echo "npm install -g web-component-tester-custom-runner wct-browserstack";
	return 1;
fi

if [[ -z ${ycliWctBrowserstackUsername} || -z ${ycliWctBrowserstackAccessKey} ]]; then
	ycliWctBrowserstackUsername=$(ycli config get wct.browserstack.username);
	ycliWctBrowserstackAccessKey=$(ycli config get wct.browserstack.accessKey);
fi

if [[ -z "$ycliWctBrowserstackUsername" || -z "$ycliWctBrowserstackAccessKey" || ${parameters[0]} == "login" ]]; then
	echo "Login to Browserstack:"
	echo "You can find your login at https://www.browserstack.com/accounts/settings all the way at the bottom"
	read -p 'Username: ' ycliWctBrowserstackUsername
	read -p 'Access Key: ' ycliWctBrowserstackAccessKey

	if [[ -z "$ycliWctBrowserstackUsername" || -z "$ycliWctBrowserstackAccessKey" ]]; then
		echo "[ERROR] No Login No Usage";
		return 1;
	fi

	ycli config set-global wct.browserstack.username "$ycliWctBrowserstackUsername"
	ycli config set-global wct.browserstack.accessKey "$ycliWctBrowserstackAccessKey"
fi

# Setting it globally for the npm module
export BROWSER_STACK_USERNAME="$ycliWctBrowserstackUsername";
export BROWSER_STACK_ACCESS_KEY="$ycliWctBrowserstackAccessKey";

if ! ping -c 1 browserstack.com &> /dev/null; then
	echo "[ERROR] browserstack.com is unreachable";
	return;
fi

if [[ "${parameters[0]}" == "list" ]]; then
	curl -u "$BROWSER_STACK_USERNAME:$BROWSER_STACK_ACCESS_KEY" https://api.browserstack.com/4/browsers?flat=true
	return;
fi

_ycliStartTime
echo "[START] Test Browserstack";
echo "";

myDir=$(pwd)

config="${parameters[0]}";
if [ -z "$config" ]; then
	config="desktop-fast";
fi

if [ -f "$config" ]; then
	configFile="$config";

else
	SOURCE_DIR=$(dirname "${BASH_SOURCE[0]}");
	configFile="$SOURCE_DIR/browserstack-configs/$config.js"
	if [ ! -f "$configFile" ]; then
		echo "[ERROR] No Config file found at $configFile";
		return 1;
	fi

fi

if [[ $optionSave == 1 ]]; then
	mkdir -p $(dirname  "$optionSaveFilePath")
	wct --configFile "$configFile" --root "$myDir" | tee "$optionSaveFilePath"
else
	wct --configFile "$configFile" --root "$myDir"
fi

_ycliEndTime
echo "";
echo "[DONE] Test Duration: $(printf %.2f $_ycliDuration)s";
