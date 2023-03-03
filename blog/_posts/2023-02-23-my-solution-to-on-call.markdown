---
layout: post
title:  "My Solution to On-Call"
date:   2023-02-23 12:00:00 -0800
categories: bash 
---

Given how hard of a sleeper I am, when it comes my turn to be the dreaded on-call analyst, I found two options:

Set numerous alarms to wake up every hour or so and check the phone.
Amplify and extend the ringer on the on-call phone.

I made it one week on the first option.

Finding a quick hack to monitor a Pulse Audio input, I wrote a short bash script to monitor my webcam microphone and if triggered, play a siren in a infinite while loop. After a few additions and revisions I’ve published version 0.0.1, and shortly after 0.0.2, of the code.

The program as a whole is very basic, grepping the output of parec to detect input. The volume level of the input device is set by the script to allow for some filtering of quieter sounds and results in less false positives. I will be attempting to improve the rate of false postives but don’t expect much, unless I go a more complex route involving more intelligent audio processing.

A helper oncall command line utility is provided for quick management of the service. For example, I can use oncall -s 3600 start to start the service in one hour. The script will also check that the service successfully started. If it was not, the alarm will sound. If you are alerted for a false positive, you can use oncall restart to restart stop and then start the service once more. The -s option can be used here as well to set a delay in the restart (stop immediately then start in x seconds).

Feel free to use or contribute to the script. Source code can be found here. RPM releases are also available on GitHub.
