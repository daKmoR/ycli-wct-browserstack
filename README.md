ycli wct browserstack
=============

Installation
------------

```
// make sure you have ycli installed
npm install -g ycli

// install
npm install -g ycli-wct-browserstack
```

Usage
-----

Just open a terminal and type

```
ycli wct browsertack <tab> <tab>
```

Should show something like this
```
chrome-latest-windows-10   edge-latest-windows-10     ie-11-windows-7            list                       safari-9.1-osx-el-capitan
desktop                    firefox-latest-windows-10  iphone-6s-ios-9.3          login                      wct
desktop-fast               ie-11-windows-10           iphone-7-ios-10.3          safari-10.1-osx-sierra
```

Go to on of your elements that has webcomponent tester tests and run
```
ycli wct browsertack
```

which will run the "desktop-fast" test which is latest Chrome, Firefox and IE11

Use autocomplete (tab, tab) to show all Commands or SubCommands.
