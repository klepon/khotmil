# khotmil

A new Flutter project.

## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Lab: Write your first Flutter app](https://flutter.dev/docs/get-started/codelab)
- [Cookbook: Useful Flutter samples](https://flutter.dev/docs/cookbook)

For help getting started with Flutter, view our
[online documentation](https://flutter.dev/docs), which offers tutorials,
samples, guidance on mobile development, and a full API reference.

## build and publish

for building read this https://flutter.dev/docs/deployment/android

$ flutter build appbundle

## wireless debuging

connect reconnect with wifi

https://developer.android.com/studio/command-line/adb#wireless

 connect usb

  $ adb tcpip 5555

 disconnect usb

  $ adb connect device_ip_address // Settings > About phone > Status > IP address

confirm deviced connected

 $ adb devices

Reconnect when connection lost

 $ adb connect

Restart connection and do all the step

 $ adb kill-server

## improvment

## reskin and relogic

- delete admin on delete group -> tinggal test

- join group - photo user jadi photo group saat response sukses

- group detail reskin join
- group detail reskin update progress
- group detail, click user name show profile info

- group update restart round -> check aslo admin
- group reskin update group for admin non owner
- group detail add admin for admin non owner

- add api notification for update or news release on register with key

- user menu in add drawer
-- edit akun - show admin list
-- share

- fix image resize using flutter core
