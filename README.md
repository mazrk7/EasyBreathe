# EasyBreathe

Prototype of an EasyBreathe application developed for the Mobile Healthcare & Machine Learning course at Imperial College London.

EasyBreathe is a platform that intends to detect and manage stress levels in users. This platform is composed of two wearable hardware components: an iPhone and an Apple Watch. From a software perspective, EasyBreathe is divided into two segments: an iOS app and a watchOS app.

The iOS app provides the main graphical interface to our platform and is also responsible for any bulk data processing. Over a Bluetooth connection, the Watch app connects heart rate and accelerometer feeds of data to the iOS app and displays these readings through a user interface. Both the iOS and watchOS apps also administer therapeutic treatment for chronic stress through their respective graphical interfaces.

Dependencies:

HealthKit framework - https://developer.apple.com/reference/healthkit

OpenCV framework for iOS development - http://docs.opencv.org/2.4/doc/tutorials/introduction/ios_install/ios_install.html

Contributors: Mark Zolotas, Charitos Charitou, Pascal Loose
