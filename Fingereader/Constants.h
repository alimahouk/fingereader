//
//  Constants.h
//  Scapes
//
//  Created by Ali Razzouk on 31/7/13.
//  Copyright (c) 2013 Ali Mahouk. All rights reserved.
//

#ifndef SHConstants_h
#define SHConstants_h

/*  --------------------------------------------
    ---------- Runtime Environment -------------
    --------------------------------------------
 */

#define SH_DEVELOPMENT_ENVIRONMENT      NO
#define IS_IOS7                         kCFCoreFoundationVersionNumber > kCFCoreFoundationVersionNumber_iOS_6_1

/*  ---------------------------------------------
    ------------------- API ---------------------
    ---------------------------------------------
 */

#define SH_DOMAIN                           @"alimahouk.com" // alimahouk.dlinkddns.com:2703
#define WORDNIK_API_KEY                     @"replace-with-your-wordnik-api-key"

/*  ---------------------------------------------
    ---------- Application Interface ------------
    ---------------------------------------------
 */

#define IS_IPHONE_5                     ( fabs( (double)[ [UIScreen mainScreen] bounds].size.height - (double)568 ) < DBL_EPSILON )

#define RADIANS_TO_DEGREES(radians)     ((radians) * (180.0 / M_PI))
#define DEGREES_TO_RADIANS(angle)       ((angle) / 180.0 * M_PI)

// Fonts
#define MAIN_FONT_SIZE                  18
#define MIN_MAIN_FONT_SIZE              15
#define SECONDARY_FONT_SIZE             12
#define MIN_SECONDARY_FONT_SIZE         10

typedef enum {
    SHStrobeLightPositionFullScreen = 1,
    SHStrobeLightPositionStatusBar,
    SHStrobeLightPositionNavigationBar
} SHStrobeLightPosition;

#endif