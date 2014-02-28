//
//  Signal.m
//  SwitchTower
//
//  Created by Robert Bowdidge on 9/14/13.
// Copyright (c) 2013, Robert Bowdidge
// All rights reserved.
//
// Redistribution and use in source and binary forms, with or without
// modification, are permitted provided that the following conditions
// are met:
// 1. Redistributions of source code must retain the above copyright
//    notice, this list of conditions and the following disclaimer.
// 2. Redistributions in binary form must reproduce the above copyright
//    notice, this list of conditions and the following disclaimer in the
//    documentation and/or other materials provided with the distribution.
//
// THIS SOFTWARE IS PROVIDED BY THE AUTHOR AND CONTRIBUTORS ``AS IS'' AND
// ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
// IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
// ARE DISCLAIMED.  IN NO EVENT SHALL THE AUTHOR OR CONTRIBUTORS BE LIABLE
// FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
// DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS
// OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION)
// HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT
// LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY
// OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF
// SUCH DAMAGE.
//

#import "Signal.h"

@implementation Signal

// Creates a signal facing trafficDirection at cell (x,y).
+ (id) signalControlling: (enum TimetableDirection) trafficDirection X: (int) x Y: (int) y {
    Signal *theSignal = [[Signal alloc] init];
    theSignal.trafficDirection = trafficDirection;
    theSignal.x = x;
    theSignal.y = y;
    theSignal.isGreen = FALSE; 
    return [theSignal autorelease];
}

// Sets the current state of the signal.
- (void) setGreen: (BOOL) green {
    self.isGreen = green;
}

- (NSString*) description {
    return [NSString stringWithFormat: @"<Signal %d,%d color: %s>",
            self.x, self.y, (self.isGreen ? "green" : "red")];
    
}
@end
