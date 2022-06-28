//
//  Scope.m
//  FlickrImageViewer
//
//  Created by LAP14121 on 28/06/2022.
//

#import "Scope.h"

void ext_executeCleanupBlock (__strong ext_cleanupBlock_t *block) {
    (*block)();
}

