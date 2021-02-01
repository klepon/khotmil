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

$ flutter build appbundle // create bundle

$ cd release folder // go to bundle folder

$ flutter build apk // create apk

$ cd release folder // go to apk folder

$ flutter install // install on device via cable

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

- upload image long response
- group option open/private; open anyone can joint, private need admin approval

## reskin and relogic

- x undangan pindah ke orange area
- notifikasi update dalam bentuk modal dan harus update, harus mark juga ver yg sekarang
- nama kasih underline
- kluar juz ganti button keluar juz
- kasi button keluar group atas kanan bisa kapan saja
- tutup putaran dan undangan anggota dibuat 2 baris tipis per button 
- gabung group order: nama, alamat, dekat saya
- search group name use auto complete, min 3 karakter

- fix image resize using flutter core

digitalamalindonesia


