//
//  IconList.swift
//  Budget Tracker
//
//  Created by Mikhailo Dovhyi on 17.12.2021.
//  Copyright © 2021 Misha Dovhiy. All rights reserved.
//

#if canImport(UIKit)
import UIKit
#endif
import Foundation
class Icons {
    
    var icons:[IconsData]  {
        get {

            return [
                IconsData(sectionName: "", data: allIcons)
            ]
        }
    }
    
    private var allIcons:[String] {
        return [
            "hand.thumbsup.fill",
            "hand.thumbsdown.fill",
            "dollarsign.circle.fill",
            "flame.fill",
            "fork.knife",
            "cup.and.saucer.fill",
            "takeoutbag.and.cup.and.straw.fill",
            "fuelpump.fill",
            "gift.fill",
            "globe.americas.fill",
            "graduationcap.fill",
                        "guitars.fill",
                        "gyroscope",
                        "heart.fill",
                        "heart.slash.fill",
                        "house.fill",
                        "key.fill",
                        "leaf.fill",
                        "lightbulb.fill",
                        "lock.fill",
                        "mic.fill",
                        "music.mic",
                        "music.note",
            "paintbrush.pointed.fill",
            "paintpalette.fill",
            "peacesign",
            "ladybug.fill",
            "ant.fill",
            "mustache.fill",
            "nose.fill",
            "hand.raised.fill",
            "face.smiling.fill",
            "person.3.sequence.fill",
            "person.fill",
            "figure.stand",
            "figure.walk",
            "tortoise.fill",
            "hare.fill",
            "pawprint.fill",
            "folder.fill",
            "envelope.fill",
            "phone.fill",
            "candybarphone",
            "simcard.fill",
            "pianokeys.inverse",
            "pin.fill",
            "play.rectangle.fill",
            "poop",
            "power.circle.fill",
            "powerplug.fill",
            "printer.fill",
            "puzzlepiece.extension.fill",
            "rectangle.and.hand.point.up.left.fill",
            "scanner.fill",
            "tv.inset.filled",
            "desktopcomputer",
            "pc",
            "display.2",
            "macwindow",
            "keyboard.fill",
            "cpu",
            "camera.fill",
            "gamecontroller.fill",
            "earbuds",
            "headphones",
            "flashlight.on.fill",
            "scissors",
            "screwdriver.fill",
            "hammer.fill",
            "wrench.and.screwdriver.fill",
            "wrench.fill",
            "shield.fill",
            "lungs.fill",
            "waveform.path.ecg.rectangle.fill",
            "stethoscope",
            "bandage.fill",
            "pills.fill",
            "mouth.fill",
            "eye.fill",
            "eyebrow",
            "eyeglasses",
            "comb.fill",
            "stopwatch.fill",
            "suit.club.fill",
            "suit.diamond.fill",
            "suit.heart.fill",
            "suit.spade.fill",
            "suitcase.cart.fill",
            "tag.fill",
            
            "terminal.fill",
            "testtube.2",
            "theatermasks.fill",
            "ticket.fill",
            "film",
            "trash.fill",
            "tray.fill",
            "tshirt.fill",
            "umbrella.fill",
            "unknown",
            "photo.fill",
            "waveform.path",
            "alarm.fill",
            "clock.fill",
            "hourglass.bottomhalf.filled",
            "align.horizontal.center.fill",
            "atom",
            "bag.fill",
            "battery.100",
            "battery.25",
            "battery.50",
            "battery.75",
            "bed.double.fill",
            "bell.fill",
            "binoculars.fill",
            "minus.plus.batteryblock.fill",
            "bolt.batteryblock.fill",
            "magazine.fill",
            "newspaper.fill",
            "text.book.closed.fill",
            "books.vertical.fill",
            "briefcase.fill",
            "building.2.fill",
            "building.columns.fill",
            "banknote.fill",
            "creditcard.fill",
            "scroll.fill",
            "airplane",
            "tram.fill",
            "ferry.fill",
            "bus",
            "car.fill",
            "cart.fill",
            "burn",
            "chart.pie.fill",
            "checkerboard.rectangle",
            "cloud.bolt.fill",
            "cloud.bolt.rain.fill",
            "cloud.rain.fill",
            "cloud.snow.fill",
            "sun.haze.fill",
            "sun.max.fill",
            "moon.fill",
            "thermometer.snowflake",
                            "crown.fill",
                            "curlybraces.square.fill",
                            "cylinder.split.1x2.fill",
                            "dice.fill",
            "flag.fill",
            "drop.fill",
                        
        ]
    }
    

    

    
    struct IconsData {
        let sectionName: String
        let data:[String]
        
    }
}
