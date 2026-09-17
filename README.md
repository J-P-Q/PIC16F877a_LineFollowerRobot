# PIC16F877a_LineFollowerRobot
A PIC16F877a based line follower robot interfaced with three IR sensors and a bang bang control logic programmed in PIC assembly. This was a group term end project for my Microprocessors and Microcontroller Laboratory class. 

# Hardware
- PIC16F877a
- TCRT5000 Module (3x)
- TB6612FNG motor driver
- DG01D motor (2x)
- 5V regulator (an Arduino nano was used as a voltage regulator for this project)

# How it works
Three TCRT5000 modules in a row detect the line position. The control logic reads the three bit combination and drives the motors accordingly.
- Line center: equal duty cycle on both wheels
- Hard turn: one wheel at full duty cycle, other wheel turned off
- Soft turn: one wheel at a reduced duty cycle, other wheel turned off

# Development
Initially used an L298n motor driver but switched to the TB6612FNG due to insufficient power going to the motor with four NiMH batteries. Traction issue during testing was resolved by adding spare batteries toward the rear drive wheels. 

# Demo
[Watch demo on Youtube] https://youtube.com/shorts/SBsvlVl4gIc?feature=share

# Build
Assembled and programmed using MPLAB IDE v8.50
