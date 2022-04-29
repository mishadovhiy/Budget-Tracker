//
//  IconList.swift
//  Budget Tracker
//
//  Created by Mikhailo Dovhyi on 17.12.2021.
//  Copyright © 2021 Misha Dovhiy. All rights reserved.
//

import UIKit

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
                        "drop.fill",
                        "envelope.fill",
                        "eye.fill",
                        "eyebrow",
                        "eyeglasses",
                        "face.smiling.fill",
                        "ferry.fill",
                        "figure.stand",
                        "figure.walk",
                        "film",
                        "flag.fill",
                        "flame.fill",
                        "flashlight.on.fill",
                        "folder.fill",
                        "fork.knife",
                        "fuelpump.fill",
                        "gamecontroller.fill",
                        "gift.fill",
                        "globe.americas.fill",
                        "graduationcap.fill",
                        "guitars.fill",
                        "gyroscope",
                        "hammer.fill",
                        "hand.raised.fill",
                        "hare.fill",
                        "headphones",
                        "heart.fill",
                        "heart.slash.fill",
                        "hourglass.bottomhalf.filled",
                        "house.fill",
                        "key.fill",
                        "keyboard.fill",
                        "ladybug.fill",
                        "leaf.fill",
                        "lightbulb.fill",
                        "lock.fill",
                        "lungs.fill",
                        "macwindow",
                        "magazine.fill",
                        "mail.fill",
                        "map.fill",
                        "mappin",
                        "mic.fill",
                        "mouth.fill",
                        "music.mic",
                        "music.note",
                        "mustache.fill",
                        "newspaper.fill",
                        "nose.fill",
            "paintbrush.pointed.fill",
            "paintpalette.fill",
            "pawprint.fill",
            "peacesign",
            "person.3.sequence.fill",
            "person.fill.questionmark",
            "person.fill",
            "person.text.rectangle.fill",
            "phone.fill",
            "pianokeys.inverse",
            "pills.fill",
            "pin.fill",
            "play.rectangle.fill",
            "poop",
            "power.circle.fill",
            "powerplug.fill",
            "printer.fill",
            "puzzlepiece.extension.fill",
            "rectangle.and.hand.point.up.left.fill",
            "scanner.fill",
            "scissors",
            "screwdriver.fill",
            "scroll.fill",
            "shield.fill",
            "simcard.fill",
            "stethoscope",
            "stopwatch.fill",
            "suit.club.fill",
            "suit.diamond.fill",
            "suit.heart.fill",
            "suit.spade.fill",
            "suitcase.cart.fill",
            "tag.fill",
            "takeoutbag.and.cup.and.straw.fill",
            "terminal.fill",
            "testtube.2",
            "text.book.closed.fill",
            "theatermasks.fill",
            "thermometer.snowflake",
            "ticket.fill",
            "tortoise.fill",
            "tram.fill",
            "trash.fill",
            "tray.fill",
            "tshirt.fill",
            "tv.inset.filled",
            "desktopcomputer",
            "pc",
            "display.2",
            "earbuds",
            "umbrella.fill",
            "unknown",
            "photo.artframe",
            "photo.fill",
            "waveform.path.ecg.rectangle.fill",
            "waveform.path",
            "wrench.and.screwdriver.fill",
            "wrench.fill",
            "airplane",
            "alarm.fill",
            "align.horizontal.center.fill",
            "ant.fill",
            "atom",
            "bag.fill",
            "bandage.fill",
            "banknote.fill",
            "battery.100",
            "battery.25",
            "battery.50",
            "battery.75",
            "bed.double.fill",
            "bell.fill",
                            "binoculars.fill",
            "minus.plus.batteryblock.fill",
                            "bolt.batteryblock.fill",
                           "bolt.horizontal.fill",
                            "books.vertical.fill",
                            "briefcase.fill",
                            "building.2.fill",
                            "building.columns.fill",
                            "burn",
                            "bus",
                            "camera.fill",
                            "candybarphone",
                            "car.fill",
                            "cart.fill",
                            "character.book.closed.fill",
                            "chart.pie.fill",
                            "checkerboard.rectangle",
                            "clock.fill",
                            "cloud.bolt.fill",
                            "cloud.bolt.rain.fill",
                            "cloud.rain.fill",
                            "cloud.snow.fill",
            "sun.haze.fill",
            "sun.max.fill",
            "powersleep",
                            "comb.fill",
                            "cpu",
                            "creditcard.fill",
                            "crown.fill",
                            "cup.and.saucer.fill",
                            "curlybraces.square.fill",
                            "cylinder.split.1x2.fill",
                            "dice.fill",
                        
        ]
    }
    

    

    
    struct IconsData {
        let sectionName: String
        let data:[String]
        
    }
}
